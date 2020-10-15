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
	def __init__(self,vehicle):
		self.vehicle = vehicle

	
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

		location = self.get_location()
		print(f'In step straight-----{kmh}----{location}')

		return [kmh, location.x-19]





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

