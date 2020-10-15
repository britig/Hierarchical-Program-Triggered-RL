#!/usr/bin/env python

# Copyright (c) 2020 Briti Gangopadhyay
# authors: Briti Gangopadhyay
# affiliation : IIT kharagpur Formal Methods Lab
# Project : Hierarchical Program Triggered RL Agents (HPRL)
# Class NNAgent

# ==============================================================================
# -- Class for triggering different RL agents based on symbolic rules
# -- The following safety assertion are also checked in run_step() function
# -- Stop at Red Lighth
# -- Maintain Longitudinal and Lateral safe distance
# -- Junction priority (This is implemented in _is_junction_hazard in agent.py)
# -- Lane clearace before lane change
# ==============================================================================

""" This module implements a HPRL agent that follows a route following given
waypoints and avoiding other vehicles.
The agent also responds to traffic lights.
Rquires world.vehicle as a parameter """

import carla
from agents.navigation.agent import Agent, AgentState
from agents.navigation.local_planner import LocalPlanner
from agents.tools.misc import get_speed,target_magnitude

#For loading neural network model
from keras.models import load_model
import numpy as np
import tensorflow as tf




from enum import Enum

#Global varaible to count time taken by blocked variable
time_count = 0
#Variables for lane change if a vehicle block is found ahead
lane_change = False
next_lane_waypoint = 0

class NNAgent(Agent):

	def __init__(self, vehicle, world_map, route_list, target_speed=30):
		"""
		:param vehicle: actor to apply to local planner logic onto
		"""
		super(NNAgent, self).__init__(vehicle)

		#Proximity threshold to other vehicles
		self.vehicle = vehicle
		self._proximity_threshold = 15.0  # meters
		self.route_list = route_list
		self.route_count = 0
		self.world_map = world_map
		#Threshold for vehicle blocking
		self._blocking_threshold = 20

		self.prev_target_diff = 200

		#Initializing Local Planner to traffict light and vehicle distance calculation
		#Required for detecting traffic lights
		self._local_planner = LocalPlanner(self._vehicle)

		#Initial agent state is always set to navigating
		self._state = AgentState.NAVIGATING
		#Load the trained DQN models
		self.straight_model = load_model('models/Straight_Model_DQN.h5')
		self.right_turn_model = load_model('models/Right_Turn_DQN.h5')
		self.left_turn_model = load_model('models/Left_Turn_DQN.h5')
		self.left_lane_static = load_model('models/Left_Lane_DQN.h5')
		self.right_lane_static = load_model('models/Right_Lane_DQN.h5')
		self.left_lane_model  =  tf.keras.models.load_model('models/Left_Lane500.h5')
		#Variable for detecting junction
		self.vehicle_junction_hazard = False
		self.vehicle_crossing = None
		#Variables for going around static obstacles
		self.static_obstacle = False
		self.static_lane_change = False
		self.first_lane_reached = False
		
	# ==============================================================================
	# -- Straight Action -----------------------------------------------------------
	# ==============================================================================
	def choose_action_straight(self,choice):
		action = []
		#break
		#Drive straight slow
		if choice == 0:
			action = [0.5, 0, 0, False]
		elif choice == 1:
			action = [0.6, 0, 0, False]
		elif choice == 2:
			action = [0.3, 0, 0, False]
		elif choice == 3:
			action = [0.4, 0, 0, False]
		else:
			action = [0.8, 0, 0, False]
		return action

	# ==============================================================================
	# -- Right Turn Action ---------------------------------------------------------
	# ==============================================================================
	def choose_action_rightturn(self,choice):
		if choice == 0:
			action = [0.5, 0.6, 0.0, False]
		#Steer high
		elif choice == 1:
			action = [0.5, 0.2, 0.0, False]
		elif choice == 2:
			action = [0.5, 0.5, 0.0, False]
		elif choice == 3:
			action = [0.5, 0.6, 0.0, False]
		elif choice == 3:
			action = [0.6, 0.7, 0.0, False]
		else:
			action = [0.5, 1.0, 0.0, False]
		return action

	# ==============================================================================
	# -- Left Turn Action ---------------------------------------------------------
	# ==============================================================================
	def choose_action_leftturn(self,choice):
		if choice == 0:
			action = [0.5, -0.2, 0.0, False]
		elif choice == 1:
			action = [0.6, -0.7, 0.0, False]
		elif choice == 2:
			action = [0.8, -0.5, 0.0, False]
		elif choice == 3:
			action = [0.5, -0.6, 0.0, False]
		else:
			action = [0.7, -1.0, 0.0, False]
		return action

	# ==============================================================================
	# -- Left Lane Change ----------------------------------------------------------
	# ==============================================================================
	def choose_action_leftlanechange(self,choice):
		if choice == 0:
			#Steer left
			action = [0.5, -0.2, 0.0, False]
		elif choice == 1:
			action = [0.5, 0.12, 0.0, False]
		else:
			action = [1.0, 1.0, 0.0, False]
		return action

	def choose_action_leftlanechange_static(self,choice):
		if choice == 0:
			#Steer left
			action = [0.6, -0.19, 0.0, False]
		elif choice == 1:
			action = [0.5, 0.24, 0.0, False]
		elif choice == 2:
			action = [0.5, 0.3, 0.0, False]
		elif choice == 3:
			action = [0.6, -0.25, 0.0, False]
		else:
			action = [1.0, 1.0, 0.0, False]
		return action

	def choose_action_rightlanechange_static(self,choice):
		if choice == 0:
			#Steer left
			action = [0.6, 0.24, 0.0, False]
		elif choice == 1:
			action = [0.6, -0.15, 0.0, False]
		elif choice == 2:
			action = [0.5, 0.3, 0.0, False]
		elif choice == 3:
			action = [0.5, -0.2, 0.0, False]
		else:
			action = [1.0, 1.0, 0.0, False]
		return action

	
	# Method implementing the supervisory controller, this method is invoked
	# at every step of the simulation via the game_loop method in the main controller 
	# Responsible for detecting if there is a red light or vehicle/junction hazard ahead
	# Calls nn_control() in case of no hazards to initiate the RL controller
	# @Parameters : self, debug if debug = True the print logs are avialable
	# @Return : Vehicle control in terms of steering and acceleration
	def run_step(self,debug):
		"""
		Execute one step of navigation.
		:Check for lights, junction block and proximity block
		:return: carla.VehicleControl
		"""
		global time_count
		global lane_change
		global next_lane_waypoint
		# is there an obstacle in front of us?
		hazard_detected = False

		# retrieve relevant elements for safe navigation, i.e.: traffic lights
		# and other vehicles, static props (occupancy grid maps)
		actor_list = self._world.get_actors()
		vehicle_list = actor_list.filter("*vehicle*")
		lights_list = actor_list.filter("*traffic_light*")
		prop_list = actor_list.filter("*static.prop.streetbarrier*")
		if(len(prop_list)==0 and len(actor_list.filter("*static.prop.container*"))!=0):
			prop_list = actor_list.filter("*static.prop.container*")

		#print(f'=============== prop list {prop_list}')

		#Get location and current waypoint
		location = self.vehicle.get_location()
		waypoint = self.world_map.get_waypoint(location)


		# check possible longitudinal and lateral obstacles
		vehicle_state, vehicle = self._is_vehicle_hazard(vehicle_list)
		if vehicle_state and not lane_change and not self.static_lane_change:
			if debug:
				print('!!! VEHICLE BLOCKING AHEAD [{}])'.format(vehicle.id))
			time_count =  time_count + 1
			if(time_count>self._blocking_threshold):
				print(f'------- Blocked more than threshold Perform lane change manouver ---- {time_count}')
				print(f'current location {location}')
				lane_change = True
				next_lane_waypoint = waypoint.get_left_lane()
				print(f'Left lane--------{waypoint.get_left_lane().transform.location.x}-------{waypoint.get_left_lane().transform.location.y}')

			self._state = AgentState.BLOCKED_BY_VEHICLE
			hazard_detected = True

		# check for the state of the traffic lights
		light_state, traffic_light = self._is_light_red(lights_list)
		if light_state:
			if debug:
				print('=== RED LIGHT AHEAD [{}])'.format(traffic_light.id))

			self._state = AgentState.BLOCKED_RED_LIGHT
			hazard_detected = True

		#Check the if there is a junction class between ego and another vehicle
		#If there is a junction class check for priority
		if(not self.vehicle_junction_hazard):
			#Return True only if another vehicle has higher priority
			self.vehicle_junction_hazard, self.vehicle_crossing = self._is_junction_hazard(vehicle_list)
		#Check if the priority vehicle is still in junction
		if self.vehicle_junction_hazard and self.world_map.get_waypoint(self.vehicle_crossing.get_location()).is_junction:
			self._state = AgentState.BLOCKED_IN_JUNCTION
			if debug:
				print(f'=== OTHER VEHICLE CROSSING JUNCTION {self.vehicle_crossing.id}')
			control = self.emergency_stop()
			return control
		else:
			self.vehicle_junction_hazard = False
			self.vehicle_crossing = None

		#Check for static obstacles on the route
		if(len(prop_list)!=0) and not self.static_lane_change:
			self.static_obstacle, prop = self._is_static_obstacle_ahead(prop_list)
			if self.static_obstacle:
				print(f'=== VEHICLE BLOCKED BY STATIC OBSTACLE======={prop.id}')
				next_lane_waypoint = waypoint.get_left_lane()
				print(f'next lane id ========== {next_lane_waypoint.lane_id}')
				print(f'current lane id ========== {waypoint.lane_id}')
				print(f'Next waypoint left lane=========={next_lane_waypoint.transform}')
				#Check if there is a vehicle within n meters
				self.static_lane_change = self._is_next_lane_clear(next_lane_waypoint,vehicle_list)
				print(f'Lane clearance value==========={self.static_lane_change}')
				#In case lane change clearance is not available stay stopped
				if not self.static_lane_change:
					print(f'I am STOPPED')
					control = self.emergency_stop()
					return control
		
		if hazard_detected and not lane_change:
			control = self.emergency_stop()
		elif lane_change:
			print(f'current transform {self.vehicle.get_transform()}')
			vehicle_transform = self.vehicle.get_transform()
			print(f'current location {next_lane_waypoint.lane_id}===={waypoint.lane_id}')
			print(f'next lane ============= {next_lane_waypoint.transform}')
			while(next_lane_waypoint.lane_id!=waypoint.lane_id or abs(abs(int(vehicle_transform.rotation.yaw))-abs(int(next_lane_waypoint.transform.rotation.yaw)))>2):
				#Observation variables
				kmh = get_speed(self.vehicle)
				vehicle_transform = self.vehicle.get_transform()
				yaw_vehicle = vehicle_transform.rotation.yaw
				delta_yaw = abs(abs(int(vehicle_transform.rotation.yaw))-abs(int(next_lane_waypoint.transform.rotation.yaw)))
				state = [kmh,yaw_vehicle,delta_yaw]
				state = np.reshape(state, (1,3))
				choice = self.left_lane_model.predict(state)
				action = self.choose_action_leftlanechange(np.argmax(choice))
				print(f"action lane change ------------------> {action}")
				control = carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3])
				return control
			lane_change=False
			control = self.nn_control()
			time_count = 0
		#For subsequent steer around lane change maneuver in case of static obstacle
		elif self.static_lane_change:
			while(waypoint.lane_id!=next_lane_waypoint.lane_id or self.vehicle.get_transform().rotation.yaw<-1.5) and not self.first_lane_reached:
				print(f'=======Left Lane Change=====')
				kmh = get_speed(self.vehicle)
				vehicle_transform = self.vehicle.get_transform()
				yaw_vehicle = vehicle_transform.rotation.yaw
				delta_yaw = abs(abs(int(179+vehicle_transform.rotation.yaw))-abs(int(next_lane_waypoint.transform.rotation.yaw)))
				lane_id = waypoint.lane_id
				state = [kmh,yaw_vehicle,lane_id,delta_yaw]
				state = np.reshape(state, (1,4))
				choice = self.left_lane_static.predict(state)
				action = self.choose_action_leftlanechange_static(np.argmax(choice))
				control = carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3])
				return control
			self.first_lane_reached = True
			next_lane_waypoint = waypoint.get_right_lane()
			while(waypoint.lane_id!=-1 or self.vehicle.get_transform().rotation.yaw>1):
				print(f'=======Right Lane Change=====')
				kmh = get_speed(self.vehicle)
				vehicle_transform = self.vehicle.get_transform()
				yaw_vehicle = vehicle_transform.rotation.yaw
				delta_yaw = abs(abs(int(vehicle_transform.rotation.yaw))-abs(int(next_lane_waypoint.transform.rotation.yaw)))
				lane_id = waypoint.lane_id
				print(f'current transform {self.vehicle.get_transform()}')
				state = [kmh,yaw_vehicle,lane_id,delta_yaw]
				state = np.reshape(state, (1,4))
				choice = self.right_lane_static.predict(state)
				action = self.choose_action_rightlanechange_static(np.argmax(choice))
				if(waypoint.lane_id==-1 ):
					action[1] = -0.14
				control = carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3])
				return control
			self.static_obstacle = False
			self.static_lane_change = False
			control = self.nn_control()
		else:
			#print(f'current transform {self.vehicle.get_transform()}')
			self._state = AgentState.NAVIGATING
			# standard local planner behavior
			control = self.nn_control()

		return control

	# ==============================================================================
	# -- Neural Network controllers when no assertion violations are occuring-------
	# -- Requires a set of route waypoints------------------------------------------
	# -- Returns neural network predicted action in terms of acceleration and steering
	# ==============================================================================
	def nn_control(self):
		#Retrieve the current option from 
		if self.route_count < len(self.route_list):
			option =  self.route_list[self.route_count][0]
			target_loc = self.route_list[self.route_count][2]
			curr_loc = (self.vehicle.get_location().x,self.vehicle.get_location().y)
			target_diff = target_magnitude(curr_loc,target_loc)
			#print(f'target difference ======={option}=========== {round(target_diff)}========{self.prev_target_diff}')

			if option == 'straight':
				#get_speed(self.vehicle)
				kmh = get_speed(self.vehicle)
				target_location = carla.Location(x = float(target_loc[0]), y = float(target_loc[1]))
				vehicle_waypoint = self.world_map.get_waypoint(self.vehicle.get_location())
				current_location = vehicle_waypoint.transform.location
				norm_target = self.compute_magnitude(target_location, current_location)
				obs = [kmh, norm_target,0,15]
				obs = np.reshape(obs, (1,4))
				choice = self.straight_model.predict(obs)
				action = self.choose_action_straight(np.argmax(choice[0]))
				control = carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3])
				#control = carla.VehicleControl(throttle=0.6, steer=0.0, brake=0.0, reverse=False)
			if option == 'right_turn':
				kmh = get_speed(self.vehicle)
				target_location = carla.Location(x = float(target_loc[0]), y = float(target_loc[1]))
				target_waypoint = self.world_map.get_waypoint(target_location)
				target_yaw = target_waypoint.transform.rotation.yaw
				vehicle_waypoint = self.world_map.get_waypoint(self.vehicle.get_location())
				current_location = vehicle_waypoint.transform.location
				current_yaw = vehicle_waypoint.transform.rotation.yaw
				norm_target, diff_angle = self.compute_magnitude_angle(target_location, current_location, target_yaw, current_yaw)
				state = [norm_target,diff_angle,0,kmh]
				state = np.reshape(state, (1,4))
				choice = self.right_turn_model.predict(state)
				action = self.choose_action_rightturn(np.argmax(choice))
				#print(f'action right turn ------> {action}--------target yaw==={target_yaw}--current yaw===={current_yaw}')
				control = carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3])
				#control = carla.VehicleControl(throttle=0.5, steer=0.2, brake=0.0, reverse=False)
			if option == 'left_turn':
				kmh = get_speed(self.vehicle)
				target_location = carla.Location(x = float(target_loc[0]), y = float(target_loc[1]))
				target_waypoint = self.world_map.get_waypoint(target_location)
				target_yaw = target_waypoint.transform.rotation.yaw
				vehicle_waypoint = self.world_map.get_waypoint(self.vehicle.get_location())
				current_location = vehicle_waypoint.transform.location
				current_yaw = vehicle_waypoint.transform.rotation.yaw
				norm_target, diff_angle = self.compute_magnitude_angle(target_location, current_location, target_yaw, current_yaw)
				state = [norm_target,diff_angle,0,kmh]
				state = np.reshape(state, (1,4))
				choice = self.left_turn_model.predict(state)
				action = self.choose_action_leftturn(np.argmax(choice))
				#print(f'action right turn ------> {action}--------target yaw==={target_yaw}--current yaw===={current_yaw}')
				control = carla.VehicleControl(throttle=action[0], steer=action[1], brake=action[2], reverse=action[3])
			if(round(target_diff)<=1 or round(target_diff)>self.prev_target_diff):
				self.route_count = self.route_count+1
				self.prev_target_diff = 200
				print(f'Count increased =====')
			else:
				self.prev_target_diff = round(target_diff)
		else:
			control = self.emergency_stop()
		return control

	# ==============================================================================
	# -- Utility Functions----------
	# ==============================================================================
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
		#print(diff)
		diff_angle = (abs((diff)) % 180.0)

		return (norm_target, diff_angle)

	def compute_magnitude(self, target_location, current_location):
		target_vector = np.array([target_location.x - current_location.x, target_location.y - current_location.y])
		norm_target = np.linalg.norm(target_vector)
		return norm_target
	






