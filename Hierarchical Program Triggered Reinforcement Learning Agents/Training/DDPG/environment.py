import glob
import os
import sys
import math
import time
import numpy as np
import cv2
import random
from collections import deque

#Global Setting
ROUNDING_FACTOR = 3
SECONDS_PER_EPISODE = 60
LIMIT_RADAR = 500
np.random.seed(32)
random.seed(32)
MAX_LEN = 1_000

try:
	sys.path.append(glob.glob('../../../carla/dist/carla-*%d.%d-%s.egg' % (
		sys.version_info.major,
		sys.version_info.minor,
		'win-amd64' if os.name == 'nt' else 'linux-x86_64'))[0])
except IndexError:
	pass
import carla

class CarlaVehicle(object):
	"""
	class responsable of:
		-spawning the ego vehicle
		-destroy the created objects
		-providing environment for RL training
	"""

	#Class Variables
	def __init__(self):
		self.client = carla.Client('localhost',2000)
		self.client.set_timeout(5.0)
		self.radar_data = deque(maxlen=MAX_LEN)

	def reset(self,Norender,loc):
		'''reset function to reset the environment before 
		the begining of each episode
		:params Norender: to be set true during training
		'''
		self.collision_hist = []
		self.world = self.client.get_world()
		self.map = self.world.get_map()
		'''target_location: Orientation details of the target loacation
		(To be obtained from route planner)'''
		# self.target_waypoint = carla.Transform(carla.Location(x = 1.89, y = 117.06, z=0), carla.Rotation(yaw=269.63))

		#Code for setting no rendering mode
		if Norender:
			settings = self.world.get_settings()
			settings.no_rendering_mode = True
			self.world.apply_settings(settings)

		self.actor_list = []
		self.blueprint_library = self.world.get_blueprint_library()
		self.bp = self.blueprint_library.filter("model3")[0]

		#create ego vehicle the reason for adding offset to z is to avoid collision
		init_pos = carla.Transform(carla.Location(x = loc, y = 130, z=2), carla.Rotation(yaw=180))
		self.vehicle = self.world.spawn_actor(self.bp, init_pos)
		self.actor_list.append(self.vehicle)

		#Create location to spawn sensors
		transform = carla.Transform(carla.Location(x=2.5, z=0.7))
		#Create Collision Sensors
		colsensor = self.blueprint_library.find("sensor.other.collision")
		self.colsensor = self.world.spawn_actor(colsensor, transform, attach_to=self.vehicle)
		self.actor_list.append(self.colsensor)
		self.colsensor.listen(lambda event: self.collision_data(event))
		self.episode_start = time.time()

		#Create location to spawn sensors
		transform = carla.Transform(carla.Location(x=2.5, z=0.7))
		#Radar Data Collectiom
		self.radar = self.blueprint_library.find('sensor.other.radar')
		self.radar.set_attribute("range", f"100")
		self.radar.set_attribute("horizontal_fov", f"35")
		self.radar.set_attribute("vertical_fov", f"25")

		#We will initialise Radar Data
		self.resetRadarData(100, 35, 25)

		self.sensor = self.world.spawn_actor(self.radar, transform, attach_to=self.vehicle)
		self.actor_list.append(self.sensor)
		self.sensor.listen(lambda data: self.process_radar(data))

		data = np.array(self.radar_data)
		return data[-LIMIT_RADAR:]


	def resetRadarData(self, dist, hfov, vfov):
		# [Altitude, Azimuth, Dist, Velocity]
		alt = 2*math.pi/vfov
		azi = 2*math.pi/hfov

		vel = 0;
		deque_list = []
		for _ in range(MAX_LEN//4):
			altitude = random.uniform(-alt,alt)
			deque_list.append(altitude)
			azimuth = random.uniform(-azi,azi)
			deque_list.append(azimuth)
			distance = random.uniform(10,dist)
			deque_list.append(distance)
			deque_list.append(vel)

		self.radar_data.extend(deque_list)

	#Process Camera Image
	def process_radar(self, radar):
		# To plot the radar data into the simulator
		self._Radar_callback_plot(radar)

		# To get a numpy [[vel, altitude, azimuth, depth],...[,,,]]:
		# Parameters :: frombuffer(data_input, data_type, count, offset)
		# count : Number of items to read. -1 means all data in the buffer.
		# offset : Start reading the buffer from this offset (in bytes); default: 0.
		points = np.frombuffer(buffer = radar.raw_data, dtype='f4')
		points = np.reshape(points, (len(radar), 4))
		for i in range(len(radar)):
			self.radar_data.append(points[i,0])
			self.radar_data.append(points[i,1])
			self.radar_data.append(points[i,2])
			self.radar_data.append(points[i,3])


	# Taken from manual_control.py
	def _Radar_callback_plot(self, radar_data):
		current_rot = radar_data.transform.rotation
		velocity_range = 7.5 # m/s
		world = self.world
		debug = world.debug

		def clamp(min_v, max_v, value):
			return max(min_v, min(value, max_v))

		for detect in radar_data:
			azi = math.degrees(detect.azimuth)
			alt = math.degrees(detect.altitude)
			# The 0.25 adjusts a bit the distance so the dots can
			# be properly seen
			fw_vec = carla.Vector3D(x=detect.depth - 0.25)
			carla.Transform(
			    carla.Location(),
			    carla.Rotation(
			        pitch=current_rot.pitch + alt,
			        yaw=current_rot.yaw + azi,
			        roll=current_rot.roll)).transform(fw_vec)
			
			norm_velocity = detect.velocity / velocity_range # range [-1, 1]
			r = int(clamp(0.0, 1.0, 1.0 - norm_velocity) * 255.0)
			g = int(clamp(0.0, 1.0, 1.0 - abs(norm_velocity)) * 255.0)
			b = int(abs(clamp(- 1.0, 0.0, - 1.0 - norm_velocity)) * 255.0)
			
			debug.draw_point(
		        radar_data.transform.location + fw_vec,
		        size=0.075,
		        life_time=0.06,
		        persistent_lines=False,
		        color=carla.Color(r, g, b))


	#record a collision event
	def collision_data(self, event):
		self.collision_hist.append(event)

	
	def step(self, action):
		#Apply Vehicle Action
		self.vehicle.apply_control(carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3]))


	#Method to take action by the DQN Agent for straight drive
	def step_straight(self, action, p):
		done = False
		self.step(action)
		#Calculate vehicle speed
		kmh = self.get_speed()

		if p:
			print(f'collision_hist----{self.collision_hist}------kmh----{kmh}------light----{self.vehicle.is_at_traffic_light()}')
		
		reward = 0
		if len(self.collision_hist) != 0:
			done = True
			reward = reward - 200
		elif kmh<2:
			done = False
			reward += -1
		elif kmh<40:
			done = False
			reward += 1
			reward += float(kmh/10)
		elif kmh<80:
			done = False
			reward += 8 - float(kmh/10)
		else:
			done = False
			reward += -1

		# Build in function of Carla
		if self.vehicle.is_at_traffic_light() and kmh<25:
			done = True
			reward = reward+100
		elif self.vehicle.is_at_traffic_light() and kmh>25:
			done = True
			reward = reward-100

		if self.episode_start + SECONDS_PER_EPISODE < time.time():
			done = True

		data = np.array(self.radar_data)

		return data[-LIMIT_RADAR:], [round(kmh, ROUNDING_FACTOR)] , reward, done, None


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


	"""
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

		#If target is reached and the angle is achieved	
		elif norm_target<=4.2 and diff_angle<=0.1:
			done = True
			print('target reached')
			reward = reward+100
		else:
			#More close to the target better the reward
			reward = 1*(90-diff_angle)+1*(-norm_target)
			

		if self.episode_start + SECONDS_PER_EPISODE < time.time():
			done = True

		return [norm_target,diff_angle] , reward, done, None

	#Method taken by the DQN agent to learn the overall policy
	def step_overall(self,action):
		done = False
		self.vehicle.apply_control(carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3]))
		#Calculate vehicle speed
		kmh = self.get_speed()
		reward = 0
		location = self.get_location()
		
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
		elif(location.x>19 and action[1]!=0):
			reward = reward - 10
		elif(location.x>19 and action[1]==0):
			reward = reward+10
		#Negative reward for not steering after the correct location
		elif (location.x<=19 and action[1]==0):
			reward = reward - 10
		elif(location.x<=19):
			#More close to the target better the reward
			reward = 1*(90-diff_angle)+1*(-norm_target)
		
		if kmh > 25 or kmh < 1:
			reward = reward-1
		if self.vehicle.is_at_traffic_light() and kmh<25:
			reward = reward+100
			

		if self.episode_start + SECONDS_PER_EPISODE < time.time():
			done = True

		return [kmh,norm_target,diff_angle] , reward, done, None


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

	def get_rotation(self):
		rotation = self.vehicle.get_transform().rotation
		return rotation

	
	def get_info(self):
		'''
		Get the full info of a vehicle
		:param vehicle: the vehicle whose info is to get
		:return: a tuple of x, y positon, yaw angle and half length, width of the vehicle
		'''
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
		'''
		Calculate distance from (x, y) to a certain waypoint
		:param waypoints: a list of list storing waypoints like [[x0, y0], [x1, y1], ...]
		:param x: x position of vehicle
		:param y: y position of vehicle
		:param idx: index of the waypoint to which the distance is calculated
		:return: a tuple of the distance and the waypoint orientation
		'''
		waypt = waypoints[idx]
		vec = np.array([x - waypt[0], y - waypt[1]])
		lv = np.linalg.norm(np.array(vec))
		w = np.array([np.cos(waypt[2]/180*np.pi), np.sin(waypt[2]/180*np.pi)])
		cross = np.cross(w, vec/lv)
		dis = - lv * cross
		return dis, w

	def compute_magnitude_angle(self, target_location, current_location, target_yaw, current_yaw):
		'''
		Compute relative angle and distance between a target_location and a current_location
		:param target_location: location of the target object
		:param current_location: location of the reference object
		:return: a tuple composed by the distance to the object and the angle between both objects
		'''
		target_vector = np.array([target_location.x - current_location.x, target_location.y - current_location.y])
		norm_target = np.linalg.norm(target_vector)
		current_yaw_rad = current_yaw % 360.0

		target_yaw_rad = target_yaw % 360.0
		diff = current_yaw_rad-target_yaw_rad
		print(diff)
		diff_angle = (abs((diff)) % 180.0)

		return (norm_target, diff_angle)

	def get_location(self):
		'''
			Get the position of a vehicle
			:param vehicle: the vehicle whose position is to get
			:return: speed as a float in Kmh
  		'''
		location = self.vehicle.get_location()
		return location

	"""