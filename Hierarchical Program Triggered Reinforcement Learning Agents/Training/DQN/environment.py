import glob
import os
import sys
import math
import time
import numpy as np
import cv2
import random

np.random.seed(32)
random.seed(32)

try:
	sys.path.append(glob.glob('../../carla/dist/carla-*%d.%d-%s.egg' % (
		sys.version_info.major,
		sys.version_info.minor,
		'win-amd64' if os.name == 'nt' else 'linux-x86_64'))[0])
except IndexError:
	pass
import carla
import random


#Global Setting
SECONDS_PER_EPISODE = 60
SHOW_PREVIEW = False
IM_WIDTH = 640
IM_HEIGHT = 480



class CarlaVehicle(object):
	"""
	class responsable of:
		-spawning the ego vehicle
		-destroy the created objects
		-providing environment for RL training
	"""

	#Class Variables
	SHOW_CAM = SHOW_PREVIEW
	front_camera = None
	def __init__(self):
		self.client = carla.Client('127.0.0.1',2000)
		self.client.set_timeout(5.0)
		self.im_width = IM_WIDTH
		self.im_height = IM_HEIGHT

	def reset(self,Norender):
		'''reset function to reset the environment before 
		the begining of each episode
		:params Norender: to be set true during training
		'''
		self.collision_hist = []
		self.world = self.client.get_world()
		self.map = self.world.get_map()
		'''target_location: Orientation details of the target loacation
		(To be obtained from route planner)'''
		#For right turn
		self.target_waypoint = carla.Transform(carla.Location(x = 1.89, y = 117.06, z=0), carla.Rotation(yaw=269.63))
		#For left turn
		#self.target_waypoint = carla.Transform(carla.Location(x = -72.7, y = 123.0, z=0), carla.Rotation(yaw=-88.33))

		#Code for setting no rendering mode
		if Norender:
			settings = self.world.get_settings()
			settings.no_rendering_mode = True
			self.world.apply_settings(settings)

		self.actor_list = []
		self.blueprint_library = self.world.get_blueprint_library()
		self.bp = self.blueprint_library.filter("vehicle.lincoln.mkz2017")[0]
		self.static_prop = self.blueprint_library.filter("static.prop.streetbarrier")[0]

		#create ego vehicle the reason for adding offset to z is to avoid collision
		#straight drive
		init_loc = carla.Location(x = 100, y = 130, z=2)
		self.target_loc_straight = carla.Location(x = 16.91, y = 130, z=0)
		#right turn
		#init_loc = carla.Location(x = 16.91, y = 130, z=2)
		#lane change
		#init_loc = carla.Location(x = 28.525513, y = 193.031601, z=2)
		init_pos = carla.Transform(init_loc, carla.Rotation(yaw=180))
		#left turn
		#init_loc = carla.Location(x = -86.759628, y = 137.367218, z=2)
		#left lane change
		#init_loc = carla.Location(x = 50.52, y = 135.91, z=1)
		#right lane change
		#init_loc = carla.Location(x=71.750694, y=131.111465, z=1)
		#==================For learning Lane Change Maneuver===============
		'''prop_1_loc = carla.Transform(carla.Location(x=69.970375, y=133.594208, z=0.014589), carla.Rotation(pitch=0.145088, yaw=-0.817204+90, roll=0.000000))
		prop_2_loc = carla.Transform(carla.Location(x=67.970741, y=133.622726, z=0.009964), carla.Rotation(pitch=0.119906, yaw=-0.817204+90, roll=0.000000))
		prop_3_loc = carla.Transform(carla.Location(x=83, y=130.111465, z=0.009964), carla.Rotation(pitch=0.119906, yaw=-0.817204+90, roll=0.000000))
		prop_1 = self.world.spawn_actor(self.static_prop, prop_1_loc)
		prop_2 = self.world.spawn_actor(self.static_prop, prop_2_loc)
		prop_3 = self.world.spawn_actor(self.static_prop, prop_3_loc)
		self.actor_list.append(prop_1)
		self.actor_list.append(prop_2)
		self.actor_list.append(prop_3)'''
		#init_pos = carla.Transform(init_loc, carla.Rotation(pitch=0.094270, yaw=-3.097657, roll=-1.246277))
		self.next_lane_target = self.map.get_waypoint(init_loc).get_left_lane()
		print(f'next_lane_target-----------{self.next_lane_target}')
		self.vehicle = self.world.spawn_actor(self.bp, init_pos)
		self.actor_list.append(self.vehicle)
		self.lane_id_ego = 0
		self.lane_id_target = 0
		self.yaw_vehicle = 0
		self.yaw_target_road =  0

		#Create location to spawn sensors
		transform = carla.Transform(carla.Location(x=2.5, z=0.7))

		#Create RGB front_camera
		'''self.rgb_cam = self.blueprint_library.find('sensor.camera.rgb')
		self.rgb_cam.set_attribute("image_size_x", f"{self.im_width}")
		self.rgb_cam.set_attribute("image_size_y", f"{self.im_height}")
		self.rgb_cam.set_attribute("fov", f"110")
		self.sensor = self.world.spawn_actor(self.rgb_cam, transform, attach_to=self.vehicle)
		self.actor_list.append(self.sensor)
		self.sensor.listen(lambda data: self.process_img(data))

		while self.front_camera is None:
			time.sleep(0.01)'''

		#Create Collision Sensors
		colsensor = self.blueprint_library.find("sensor.other.collision")
		self.colsensor = self.world.spawn_actor(colsensor, transform, attach_to=self.vehicle)
		self.actor_list.append(self.colsensor)
		self.colsensor.listen(lambda event: self.collision_data(event))
		self.episode_start = time.time()

	#record a collision event
	def collision_data(self, event):
		self.collision_hist.append(event)

	#Process Camera Image
	def process_img(self, image):
		i = np.array(image.raw_data)
		#print(i.shape)
		i2 = i.reshape((self.im_height, self.im_width, 4))
		i3 = i2[:, :, :3]
		if self.SHOW_CAM:
			cv2.imshow("", i3)
			cv2.waitKey(1)
		self.front_camera = i3

	
	def step(self, action):
		#Apply Vehicle Action
		self.vehicle.apply_control(carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3]))


	#Method to take action by the DQN Agent for straight drive
	def step_straight(self, action):
		done = False
		#No idea why this is not working
		self.vehicle.apply_control(carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3]))
		#Calculate vehicle speed
		kmh = self.get_speed()
		vehicle_waypoint = self.map.get_waypoint(self.vehicle.get_location())
		current_location = vehicle_waypoint.transform.location

		print(f'collision_hist-------{self.collision_hist}-------kmh{kmh}----light----{self.vehicle.is_at_traffic_light()}')
		reward = 0
		if len(self.collision_hist) != 0:
			done = True
			reward = reward -1000
		elif kmh > 30 or kmh < 20:
			reward = reward-30
		else:
			reward = reward+10

		norm_target = self.compute_magnitude(self.target_loc_straight, current_location)
		reward = reward - 0.1*norm_target

		if norm_target<=5 and kmh<=25:
			done = True
			reward = reward+1000

		if self.episode_start + SECONDS_PER_EPISODE < time.time():
			done = True
			reward = reward-1000

		location = self.get_location()

		return [kmh, norm_target,0,15] , reward, done, None


	#Method to take action by the DQN Agent for right turn
	def step_rightturn(self, action):
		done = False
		self.vehicle.apply_control(carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3]))
		#Calculate vehicle speed
		kmh = self.get_speed()
		reward = 0
		
		target_yaw = self.target_waypoint.rotation.yaw
		target_location = self.target_waypoint.location
		vehicle_waypoint = self.map.get_waypoint(self.vehicle.get_location())
		current_location = vehicle_waypoint.transform.location
		current_yaw = vehicle_waypoint.transform.rotation.yaw

		#print(f'current location  {current_location} ------- current yaw ---- {current_yaw}')

		#Return difference of distance and angle
		norm_target, diff_angle = self.compute_magnitude_angle(target_location, current_location, target_yaw, current_yaw)

		#In case of collision terminate the episode
		if len(self.collision_hist) != 0:
			done = True
			print('colided')
			reward = reward-1000

		if(action[1]!=0.2):
			reward = reward - 100

		#If target is reached and the angle is achieved	
		elif norm_target<=4.2 and diff_angle<=0.1:
			done = True
			print('target reached')
			reward = reward+1000
		else:
			#More close to the target better the reward
			reward = 0.1*(90-diff_angle)+0.1*(-norm_target)
			

		if self.episode_start + SECONDS_PER_EPISODE < time.time():
			done = True
			reward = reward-1000

		return [norm_target,diff_angle,0,kmh] , reward, done, None

	#======================LEFT TURN REWARD FUNCTION==================================
	def step_leftturn(self, action):
		done = False
		self.vehicle.apply_control(carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3]))
		#Calculate vehicle speed
		kmh = self.get_speed()
		reward = 0
		
		target_yaw = self.target_waypoint.rotation.yaw
		target_location = self.target_waypoint.location
		vehicle_waypoint = self.map.get_waypoint(self.vehicle.get_location())
		current_location = vehicle_waypoint.transform.location
		current_yaw = vehicle_waypoint.transform.rotation.yaw

		print(f'current location  {current_location} ------- current yaw ---- {current_yaw}')

		#Return difference of distance and angle
		norm_target, diff_angle = self.compute_magnitude_angle(target_location, current_location, target_yaw, current_yaw)
		print(f'norm_target {norm_target} ------- diff_angle ---- {diff_angle}')

		#In case of collision terminate the episode
		if len(self.collision_hist) != 0:
			done = True
			print('colided')
			reward = reward-1000

		#If target is reached and the angle is achieved	
		elif norm_target<=2.5 and diff_angle<=2:
			done = True
			print('target reached')
			reward = reward+1000
		else:
			#More close to the target better the reward
			reward = 0.1*(0-diff_angle)+0.1*(-norm_target)
			

		if self.episode_start + SECONDS_PER_EPISODE < time.time():
			done = True
			reward = reward-1000

		return [norm_target,diff_angle,0,kmh] , reward, done, None

	#==========================LEFT LANE CHANGE ACTION STEP===========================
	def step_leftlanechange(self,action):
		done = False
		#Calculate vehicle speed
		self.vehicle.apply_control(carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3]))
		kmh = self.get_speed()
		current_location = self.vehicle.get_location()
		current_transform = self.vehicle.get_transform()
		target_lane = self.next_lane_target
		self.lane_id_ego = self.map.get_waypoint(self.vehicle.get_location()).lane_id
		self.lane_id_target = self.next_lane_target.lane_id
		self.yaw_vehicle = self.vehicle.get_transform().rotation.yaw
		self.yaw_target_road = self.next_lane_target.transform.rotation.yaw
		print(f'----lane ego==={self.lane_id_ego}----lane target===={self.lane_id_target}----yaw ego==={self.yaw_vehicle}--yaw target==={self.yaw_target_road}')

		reward = 0
		#Difference in lane id
		if (self.lane_id_ego!=self.lane_id_target):
			if(action[1]<0):
				reward = reward + 10
			if(action[1]>0):
				reward = reward - 10
			if len(self.collision_hist) != 0:
				done = True
				print(f'COLLISION HISTORY========={self.collision_hist}====len{len(self.collision_hist)}')
				reward = reward-3000
		else:
			reward = reward+10
			if (abs(abs(int(179+self.yaw_vehicle))-abs(int(self.yaw_target_road)))>1):
				if(action[1]<0):
					reward = reward - 30
				if(action[1]>0):
					reward = reward + 30
			if len(self.collision_hist) != 0:
				done = True
				print(f'COLLISION HISTORY========={self.collision_hist}====len{len(self.collision_hist)}')
				reward = reward-1000
			if(abs(abs(int(179+self.yaw_vehicle))-abs(int(self.yaw_target_road)))<=1):
				done = True
				print('target reached')
				reward = reward+500


		
		return [kmh,self.yaw_vehicle,self.lane_id_ego,abs(abs(int(179+self.yaw_vehicle))-abs(int(self.yaw_target_road)))] , reward, done, None

	#==========================RIGHT LANE CHANGE ACTION STEP===========================
	def step_rightlanechange(self,action):
		done = False
		#Calculate vehicle speed
		self.vehicle.apply_control(carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3]))
		kmh = self.get_speed()
		current_location = self.vehicle.get_location()
		current_transform = self.vehicle.get_transform()
		target_lane = self.next_lane_target
		self.lane_id_ego = self.map.get_waypoint(self.vehicle.get_location()).lane_id
		self.lane_id_target = self.next_lane_target.lane_id
		self.yaw_vehicle = self.vehicle.get_transform().rotation.yaw
		self.yaw_target_road = self.next_lane_target.transform.rotation.yaw
		print(f'----lane ego==={self.lane_id_ego}----lane target===={self.lane_id_target}----yaw ego==={self.yaw_vehicle}--yaw target==={self.yaw_target_road}')

		reward = 0
		#Difference in lane id
		if (self.lane_id_ego!=self.lane_id_target):
			if(action[1]>0):
				reward = reward + 10
			if(action[1]<0):
				reward = reward - 10
			if len(self.collision_hist) != 0:
				done = True
				print(f'COLLISION HISTORY========={self.collision_hist}====len{len(self.collision_hist)}')
				reward = reward-3000
		else:
			reward = reward+10
			if (self.yaw_vehicle>1):
				if(action[1]>0):
					reward = reward - 10
				if(action[1]<0):
					reward = reward + 10
			if len(self.collision_hist) != 0:
				done = True
				print(f'COLLISION HISTORY========={self.collision_hist}====len{len(self.collision_hist)}')
				reward = reward-1500
			if(self.yaw_vehicle<1):
				done = True
				print('target reached')
				reward = reward+500


		
		return [kmh,self.yaw_vehicle,self.lane_id_ego,abs(abs(int(self.yaw_vehicle))-abs(int(self.yaw_target_road)))] , reward, done, None




	#Method taken by the DQN agent to learn the overall policy
	def step_overall(self,action):
		done = False
		self.vehicle.apply_control(carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3]))
		#Calculate vehicle speed
		kmh = self.get_speed()
		reward = 0
		location = self.get_location()
		sub_target_1  = carla.Transform(carla.Location(x = 16.91, y = 130, z=0))
		subtarget_2 = carla.Transform(carla.Location(x = 1.89, y = 117.06, z=0), carla.Rotation(yaw=269.63))
		target_yaw = self.target_waypoint.rotation.yaw
		target_location = self.target_waypoint.location
		vehicle_waypoint = self.map.get_waypoint(self.vehicle.get_location())
		current_location = vehicle_waypoint.transform.location
		current_yaw = vehicle_waypoint.transform.rotation.yaw

		#print(f'current location  {current_location} ------- current yaw ---- {current_yaw}')

		#Return difference of distance and angle
		norm_target, diff_angle = self.compute_magnitude_angle(target_location, current_location, target_yaw, current_yaw)

		#In case of collision terminate the episode
		if len(self.collision_hist) != 0:
			done = True
			print('colided')
			reward = reward-1000

		#If target is reached and the angle is achieved	
		if norm_target<=4.2 and diff_angle<=0.1:
			done = True
			print('target reached')
			reward = reward+100
		#Negative reward for steering before location
		reward = 1*(90-diff_angle)+1*(-norm_target)
		
		if kmh > 25 or kmh < 1:
			reward = reward-1
		if self.vehicle.is_at_traffic_light() and kmh<25:
			reward = reward+100
			

		if self.episode_start + SECONDS_PER_EPISODE < time.time():
			done = True

		return [kmh,norm_target,diff_angle] , reward, done, None


		#Method taken by the DQN agent to learn the overall policy
	def step_hierarchical(self,action,target_count):
		done = False
		self.vehicle.apply_control(carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3]))
		#Calculate vehicle speed
		kmh = self.get_speed()
		reward = 0
		location = self.get_location()
		sub_target_1  = carla.Transform(carla.Location(x = 16.91, y = 130, z=0))
		sub_target_2 = carla.Transform(carla.Location(x = 1.89, y = 117.06, z=0), carla.Rotation(yaw=269.63))
		vehicle_waypoint = self.map.get_waypoint(self.vehicle.get_location())
		current_location = vehicle_waypoint.transform.location
		current_yaw = vehicle_waypoint.transform.rotation.yaw
		norm_target = 0
		diff_angle = 0
		reward = 0
		subgoal_reached = False
		if len(self.collision_hist) != 0:
				done = True
				reward = reward -1000
		if(target_count == 0):
			target_yaw = sub_target_1.rotation.yaw
			target_location = sub_target_1.location
			if kmh > 30 or kmh < 20:
				reward = reward-10
			else:
				reward = reward+10
			norm_target = self.compute_magnitude(self.target_loc_straight, current_location)
			reward = reward - 0.1*norm_target

			if norm_target<=5 and kmh<=25:
				print('SUBGOAL 1 REACHED')
				subgoal_reached = True
				reward = reward+200

		if(target_count == 1):
			target_yaw = sub_target_2.rotation.yaw
			target_location = sub_target_2.location
			#Return difference of distance and angle
			norm_target, diff_angle = self.compute_magnitude_angle(target_location, current_location, target_yaw, current_yaw)

			#If target is reached and the angle is achieved	
			if norm_target<=4.2 and diff_angle<=0.1:
				print('SUBGOAL 2 REACHED')
				done = True
				print('target reached')
				reward = reward+400
			else:
				#More close to the target better the reward
				reward = 0.1*(90-diff_angle)+0.1*(-norm_target)

		#print(f'current location  {current_location} ------- current yaw ---- {current_yaw}')


		if self.episode_start + SECONDS_PER_EPISODE < time.time():
			print('BUDGET EXHAUSTED')
			done = True
			reward = reward -500

		return [kmh,norm_target,diff_angle,0] , reward, done, subgoal_reached, None




	def _get_obs(self):
		# State observation
		ego_trans = self.vehicle.get_transform()
		ego_x = ego_trans.location.x
		ego_y = ego_trans.location.y
		ego_yaw = ego_trans.rotation.yaw/180*np.pi
		lateral_dis, w = get_lane_dis(self.waypoints, ego_x, ego_y)
		delta_yaw = np.arcsin(np.cross(w, 
		np.array(np.array([np.cos(ego_yaw), np.sin(ego_yaw)]))))
		speed = get_speed()
		state = np.array([speed, lateral_dis, - delta_yaw])

	

	def get_vehicle(self):
		return self.vehicle

	def get_location(self):
		"""
			Get the position of a vehicle
			:param vehicle: the vehicle whose position is to get
			:return: speed as a float in Kmh
  		"""
		location = self.vehicle.get_location()
		return location

	def get_rotation(self):
		rotation = self.vehicle.get_transform().rotation
		return rotation


	def destroy(self):
		"""
			destroy all the actors
			:param self
			:return None
		"""
		print('destroying actors')
		for actor in self.actor_list:
			actor.destroy()
		print('done.')


	def get_speed(self):
		"""
			Compute speed of a vehicle in Kmh
			:param vehicle: the vehicle for which speed is calculated
			:return: speed as a float in Kmh
		"""
		vel = self.vehicle.get_velocity()
		return 3.6 * math.sqrt(vel.x ** 2 + vel.y ** 2 + vel.z ** 2)

	def get_info(self):
		"""
		Get the full info of a vehicle
		:param vehicle: the vehicle whose info is to get
		:return: a tuple of x, y positon, yaw angle and half length, width of the vehicle
		"""
		trans = self.vehicle.get_transform()
		x = trans.location.x
		y = trans.location.y
		yaw = trans.rotation.yaw / 180 * np.pi
		bb = vehicle.bounding_box
		l = bb.extent.x
		w = bb.extent.y
		info = (x, y, yaw, l, w)
		return info

	def get_lane_dis(self, waypoints, x, y, idx=2):
		"""
		Calculate distance from (x, y) to a certain waypoint
		:param waypoints: a list of list storing waypoints like [[x0, y0], [x1, y1], ...]
		:param x: x position of vehicle
		:param y: y position of vehicle
		:param idx: index of the waypoint to which the distance is calculated
		:return: a tuple of the distance and the waypoint orientation
		"""
		waypt = waypoints[idx]
		vec = np.array([x - waypt[0], y - waypt[1]])
		lv = np.linalg.norm(np.array(vec))
		w = np.array([np.cos(waypt[2]/180*np.pi), np.sin(waypt[2]/180*np.pi)])
		cross = np.cross(w, vec/lv)
		dis = - lv * cross
		return dis, w

	def compute_magnitude_angle(self, target_location, current_location, target_yaw, current_yaw):
		"""
		Compute relative angle and distance between a target_location and a current_location
		:param target_location: location of the target object
		:param current_location: location of the reference object
		:return: a tuple composed by the distance to the object and the angle between both objects
		"""
		target_vector = np.array([target_location.x - current_location.x, target_location.y - current_location.y])
		norm_target = np.linalg.norm(target_vector)
		current_yaw_rad = current_yaw % 360.0

		target_yaw_rad = target_yaw % 360.0
		diff = current_yaw_rad-target_yaw_rad
		print(diff)
		diff_angle = (abs((diff)) % 180.0)

		return (norm_target, diff_angle)

	def compute_magnitude(self, target_location, current_location):
		target_vector = np.array([target_location.x - current_location.x, target_location.y - current_location.y])
		norm_target = np.linalg.norm(target_vector)
		return norm_target

