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
ROUNDING_FACTOR = 2
SECONDS_PER_EPISODE = 30
LIMIT_RADAR = 500
np.random.seed(32)
random.seed(32)
MAX_LEN = 500

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
		self.static_prop = self.blueprint_library.filter("static.prop.streetbarrier")[0]


		#==================For learning Lane Change Maneuver===============
		# prop_1_loc = carla.Transform(carla.Location(x=69.970375, y=133.594208, z=0.014589), carla.Rotation(pitch=0.145088, yaw=-0.817204+90, roll=0.000000))
		# prop_2_loc = carla.Transform(carla.Location(x=67.970741, y=133.622726, z=0.009964), carla.Rotation(pitch=0.119906, yaw=-0.817204+90, roll=0.000000))
		# prop_3_loc = carla.Transform(carla.Location(x=83, y=130.111465, z=0.009964), carla.Rotation(pitch=0.119906, yaw=-0.817204+90, roll=0.000000))
		# prop_1 = self.world.spawn_actor(self.static_prop, prop_1_loc)
		# prop_2 = self.world.spawn_actor(self.static_prop, prop_2_loc)
		# prop_3 = self.world.spawn_actor(self.static_prop, prop_3_loc)
		# self.actor_list.append(prop_1)
		# self.actor_list.append(prop_2)
		# self.actor_list.append(prop_3)

		# These will be in left side of the road
		prop_lt_1_loc = carla.Transform(carla.Location(x=96, y=126, z=0.014589), carla.Rotation(pitch=0.145088, yaw=-0.817204, roll=0.000000))
		prop_lt_2_loc = carla.Transform(carla.Location(x=100, y=126, z=0.009964), carla.Rotation(pitch=0.119906, yaw=-0.817204, roll=0.000000))
		prop_lt_3_loc = carla.Transform(carla.Location(x=104, y=126, z=0.009964), carla.Rotation(pitch=0.119906, yaw=-0.817204, roll=0.000000))
		prop_lt_4_loc = carla.Transform(carla.Location(x=108, y=126, z=0.009964), carla.Rotation(pitch=0.119906, yaw=-0.817204, roll=0.000000))
		prop_lt_5_loc = carla.Transform(carla.Location(x=112, y=126, z=0.009964), carla.Rotation(pitch=0.119906, yaw=-0.817204, roll=0.000000))
		prop_lt_1 = self.world.spawn_actor(self.static_prop, prop_lt_1_loc)
		prop_lt_2 = self.world.spawn_actor(self.static_prop, prop_lt_2_loc)
		prop_lt_3 = self.world.spawn_actor(self.static_prop, prop_lt_3_loc)
		prop_lt_4 = self.world.spawn_actor(self.static_prop, prop_lt_4_loc)
		prop_lt_5 = self.world.spawn_actor(self.static_prop, prop_lt_5_loc)

		# These will be the end points on the road
		prop_end_rt_loc = carla.Transform(carla.Location(x=104, y=133, z=0.014589), carla.Rotation(pitch=0.145088, yaw=-0.817204+90, roll=0.000000))
		prop_end_lt_loc = carla.Transform(carla.Location(x=114, y=129.5, z=0.009964), carla.Rotation(pitch=0.119906, yaw=-0.817204+90, roll=0.000000))
		prop_start_lt_loc = carla.Transform(carla.Location(x=94, y=129.5, z=0.009964), carla.Rotation(pitch=0.119906, yaw=-0.817204+90, roll=0.000000))
		prop_end_rt = self.world.spawn_actor(self.static_prop, prop_end_rt_loc)
		prop_end_lt = self.world.spawn_actor(self.static_prop, prop_end_lt_loc)
		prop_start_lt = self.world.spawn_actor(self.static_prop, prop_start_lt_loc)

		# It will bw on right side of the road
		prop_rt_1_loc = carla.Transform(carla.Location(x=98, y=136.5, z=0.009964), carla.Rotation(pitch=0.119906, yaw=-0.817204, roll=0.000000))
		prop_rt_2_loc = carla.Transform(carla.Location(x=102, y=136.5, z=0.009964), carla.Rotation(pitch=0.119906, yaw=-0.817204, roll=0.000000))
		prop_rt_1 = self.world.spawn_actor(self.static_prop, prop_rt_1_loc)
		prop_rt_2 = self.world.spawn_actor(self.static_prop, prop_rt_2_loc)

		prop_rt_3_loc = carla.Transform(carla.Location(x=108, y=133, z=0.009964), carla.Rotation(pitch=0.119906, yaw=-0.817204, roll=0.000000))
		prop_rt_4_loc = carla.Transform(carla.Location(x=112, y=133, z=0.009964), carla.Rotation(pitch=0.119906, yaw=-0.817204, roll=0.000000))
		prop_rt_3 = self.world.spawn_actor(self.static_prop, prop_rt_3_loc)
		prop_rt_4 = self.world.spawn_actor(self.static_prop, prop_rt_4_loc)

		self.actor_list.append(prop_lt_1)
		self.actor_list.append(prop_lt_2)
		self.actor_list.append(prop_lt_3)
		self.actor_list.append(prop_lt_4)
		self.actor_list.append(prop_lt_5)

		self.actor_list.append(prop_end_lt)
		self.actor_list.append(prop_end_rt)
		self.actor_list.append(prop_start_lt)

		self.actor_list.append(prop_rt_1)
		self.actor_list.append(prop_rt_2)
		self.actor_list.append(prop_rt_3)
		self.actor_list.append(prop_rt_4)

		
		#create ego vehicle the reason for adding offset to z is to avoid collision
		# off = random.uniform(0, 3)
		# init_loc = carla.Location(x = -145 + off, y = 7.5, z=2)
		# self.init_pos = carla.Transform(init_loc, carla.Rotation(yaw=-90))
		# left lane change
		# init_loc = carla.Location(x = 50.52, y = 135.91, z=1)
		init_loc = carla.Location(x = 92, y = 134, z=1)
		self.init_pos = carla.Transform(init_loc, carla.Rotation(pitch=0.094270, yaw=0, roll=-1.246277))
		self.next_lane_target = self.map.get_waypoint(init_loc).get_left_lane()
		self.target_waypoint = carla.Transform(carla.Location(x = 110, y = 129.5, z=0), carla.Rotation(yaw=0))
		print(f'next_lane_target-----------{self.next_lane_target}')

		self.vehicle = self.world.spawn_actor(self.bp, self.init_pos)
		self.actor_list.append(self.vehicle)
		self.lane_id_ego = 0
		self.lane_id_target = 0
		self.yaw_vehicle = 0
		self.yaw_target_road =  0

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
		self.radar.set_attribute("range", f"80")
		self.radar.set_attribute("horizontal_fov", f"60")
		self.radar.set_attribute("vertical_fov", f"25")

		#We will initialise Radar Data
		self.resetRadarData(80, 60, 25)

		self.sensor = self.world.spawn_actor(self.radar, transform, attach_to=self.vehicle)
		self.actor_list.append(self.sensor)
		self.sensor.listen(lambda data: self.process_radar(data))

		data = np.array(self.radar_data)
		return data[-LIMIT_RADAR:]


	def resetRadarData(self, dist, hfov, vfov):
		# [Altitude, Azimuth, Dist, Velocity]
		alt = 2*math.pi/vfov
		azi = 2*math.pi/hfov

		vel = 0
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


	def destroy(self):
		"""
			destroy all the actors
			:param self
			:return None
		"""
		print('destroying actors')
		for actor in self.actor_list:
			actor.destroy()
		print('done')


	# ==============================================================================
	# -- Lane Change DDPG Network ------------------
	# ==============================================================================
	"""
	def left_lane_change(self, action, debug):
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
		init_location = self.init_pos.location
		norm_target, diff_angle = self.compute_magnitude_angle(target_location, current_location, target_yaw, current_yaw)
		
		
		# Approximate Radius
		
		rad = (abs(target_location.x - init_location.x) + abs(target_location.y - init_location.y)) / 2
		pie = math.pi 

		# y == 7.5 ----> (0, 3)
		# x == (-145.5,-142.5)  ----> -135
		check_1 = target_location * 1/2
		# check_2 = target_location * math.sqrt(3)/2
		
		check_1.x = init_location.x + rad * math.cos(pie/4)
		check_1.y = init_location.y - rad * math.sin(pie/4) 
		# check_2.x = init_location.x + rad * math.cos(pie/3)
		# check_2.y = init_location.y - rad * math.sin(pie/3)
		
		
		norm_1 = self.compute_magnitude(check_1, current_location)
		#norm_2 = self.compute_magnitude(check_2, current_location)
		
		# norm_1=0
		# norm_2=0

		print(f"Tar--{norm_target}---1--{norm_1}")

		if debug:
			print(f'collision_hist--{self.collision_hist}------kmh--{kmh}------norm target--{norm_target}----diff angle--{diff_angle}')

		#In case of collision terminate the episode
		if len(self.collision_hist) != 0:
			done = True
			print('collided')
			reward = reward-200

		#If target is reached and the angle is achieved	
		if norm_target<=1.5 and diff_angle<=0.5:
			done = True
			print('target reached')
			reward = reward+200
		else:
			#More close to the target better the reward
			reward += 0.2*(90-diff_angle)

			if diff_angle>45:
				val = 0.6*(-norm_1) + 0.4*(-norm_target)
			else:
				val = (-norm_target)

			reward += val*0.8

		# angle 90----0 norm 15----0

		if self.episode_start + SECONDS_PER_EPISODE < time.time():
			done = True
			reward = reward-100

		data = np.array(self.radar_data)

		return data[-LIMIT_RADAR:], [norm_target,diff_angle] , reward, done, None
	"""

	def left_lane_change(self,action):
		done = False
		#Calculate vehicle speed
		self.vehicle.apply_control(carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3]))
		kmh = self.get_speed()
		current_location = self.vehicle.get_location()
		current_transform = self.vehicle.get_transform()
		target_location = self.target_waypoint.location
		target_lane = self.next_lane_target
		norm = self.compute_magnitude(target_location, current_location)
		
		# vehicle_waypoint = self.map.get_waypoint(self.vehicle.get_location())
		self.lane_id_ego = self.map.get_waypoint(self.vehicle.get_location()).lane_id
		self.lane_id_target = self.next_lane_target.lane_id
		self.yaw_vehicle = current_transform.rotation.yaw
		self.yaw_target_road = self.next_lane_target.transform.rotation.yaw
		diff_angle = abs(abs(int(179+self.yaw_vehicle))-abs(int(self.yaw_target_road)))
		print(f'lane ego=={self.lane_id_ego}----lane target=={self.lane_id_target}----yaw ego=={self.yaw_vehicle}--yaw target=={self.yaw_target_road}')

		reward = 0
		if (self.lane_id_ego!=self.lane_id_target):
			if(action[1]<0):
				reward = reward + 30 # More Positive reward Comparative
			if(action[1]>0):
				reward = reward - 10 # Less Negative reward Comparative
			if len(self.collision_hist) != 0:
				done = True
				reward = reward-1000
		else:
			# Adding a large positive reward if the ego car is in target lane
			reward = reward+100
			if (diff_angle > 5):
				if(action[1]<0):
					reward = reward - 30 # Less Negative reward Comparative
				if(action[1]>0):
					reward = reward + 50
			if len(self.collision_hist) != 0: # More Positive reward Comparative
				done = True
				reward = reward-1000

			# If the ego car is within range of target angle
			if(diff_angle<=5):
				done = True
				reward = reward+500
		
		if norm <= 2:
			done = True
			reward = reward+500

		max_Norm = math.sqrt((110-92)**2 + (134-129.5)**2)  #18.55
		norm_reward = (max_Norm - norm)*2

		reward += norm_reward
		data = np.array(self.radar_data)

		lane = 0
		if self.lane_id_ego == self.lane_id_target:
			lane = 1 

		return data[-LIMIT_RADAR:], [kmh, self.yaw_vehicle, lane, diff_angle, norm] , reward, done, None


	def get_speed(self):
		"""
			Compute speed of a vehicle in Kmh
			:param vehicle: the vehicle for which speed is calculated
			:return: speed as a float in Kmh
		"""
		vel = self.vehicle.get_velocity()
		return 3.6 * math.sqrt(vel.x ** 2 + vel.y ** 2 + vel.z ** 2)


	def compute_magnitude_angle(self, target_location, current_location, target_yaw, current_yaw):
		'''
		Compute relative angle and distance between a target_location and a current_location
		:param target_location: location of the target object
		:param current_location: location of the reference object
		:return: a tuple composed by the distance to the object and the angle between both objects
		'''
		target_vector = np.array([target_location.x - current_location.x, target_location.y - current_location.y])
		norm_target = np.linalg.norm(target_vector)
		current_yaw_rad = abs(current_yaw)

		target_yaw_rad = abs(target_yaw) 
		diff = current_yaw_rad-target_yaw_rad
		diff_angle = (abs((diff)) % 180.0)

		return (norm_target, diff_angle)

	def compute_magnitude(self, target_location, current_location):
		target_vector = np.array([target_location.x - current_location.x, target_location.y - current_location.y])
		norm_target = np.linalg.norm(target_vector)
		return norm_target
