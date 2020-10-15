import glob
import os
import sys
import random
import time
import numpy as np
import math
import environment as env
import utility as ut
import model as md
import tensorflow as tf
from keras.models import load_model

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


# Discrete action space as of now for straight maneuver (Make this continuous using DDPG in future)
def choose_action_straight(choice):
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
	#Drive Fast
	else:
		action = [0.8, 0, 0, False]
	return action


#action space for right turn all action spaces should be continuous when using ddpg
def choose_action_rightturn(choice):
	if choice == 0:
		action = [0.5, 0.6, 0.0, False]
	#Steer high
	elif choice == 1:
		action = [0.5, 0.2, 0.0, False]
	elif choice == 2:
		action = [0.5, 0.5, 0.0, False]
	else:
		action = [0.5, 1.0, 0.0, False]
	return action


#action space for left turn
def choose_action_leftturn(choice):
	if choice == 0:
		action = [0.5, -0.2, 0.0, False]
	elif choice == 1:
		action = [0.6, -0.7, 0.0, False]
	elif choice == 2:
		action = [0.8, -0.5, 0.0, False]
	else:
		action = [0.7, -1.0, 0.0, False]
	return action

#Left Lane change action space
def choose_action_leftlanechange(choice):
	if choice == 0:
		action = [0.6, -0.15, 0.0, False]
	elif choice == 1:
		action = [0.5, 0.2, 0.0, False]
	else:
		action = [1.0, 1.0, 0.0, False]
	return action
'''def choose_action_leftlanechange(choice):
	if choice == 0:
		#Steer left
		action = [0.5, -0.2, 0.0, False]
	elif choice == 1:
		action = [0.5, 0.12, 0.0, False]
	else:
		action = [1.0, 1.0, 0.0, False]
	return action'''


#Right Lane change action space
def choose_action_rightlanechange(choice):
	if choice == 0:
		action = [0.5, 0.21, 0.0, False]
	elif choice == 1:
		action = [0.5, -0.14, 0.0, False]
	else:
		action = [1.0, -1.0, 0.0, False]
	return action


#Right Lane change action space

#overall action space
def choose_action_overall(choice):
	if choice==0:
		action = [0.5, 0, 0, False]
	elif choice==1:
		action = [0.6, 0, 0, False]
	elif choice==2:
		action = [0.5, 0.2, 0.0, False]
	elif choice==3:
		action = [0.5, 0.1, 0.0, False]
	else:
		action = [0.5, 1.0, 0.0, False]
	return action


#hierarchical action space
def choose_action_hierarchical(choice):
	if choice==0:
		action = [0.6, 0, 0, False]
	elif choice==1:
		action = [0.5, 0.2, 0, False]
	else:
		action = [1, 1, 0, False]
	return action



# ==============================================================================
# -- Trains DQN agent only for straight drive ------------------------------
# -- Scenario Right turn on Traffic Jnction ------------------------------------
# ==============================================================================
def train_straight_DQN(episodes,agent):
	#Create model
	loss = []
	straight_model = md.DQN(5,4,'Straight_Model')
	for epi in range(episodes):
		try:
				agent.reset(True)
				#Get the first state (speed, distance from junction)
				state = [0,100,0,15]
				state = np.reshape(state, (1,4))
				score = 0
				max_step = 500
				for i in range(max_step):
					choice = straight_model.act(state)
					action = choose_action_straight(choice)
					print(f"action ------------------> {action}")
					next_state, reward, done, _ = agent.step_straight(action)
					print(f'obs----------->{next_state}-----reward--- {reward} -----done--{done}')
					time.sleep(0.5)
					score += reward
					next_state = np.reshape(next_state, (1, 4))
					straight_model.remember(state, choice, reward, next_state, done)
					state = next_state
					straight_model.replay(done,epi,loss)
					if done:
						print("episode: {}/{}, score: {}".format(epi, episodes, score))
						break
				loss.append(score)
				# Average score of last 100 episode
				is_solved = np.mean(loss[-100:])
				if is_solved > 1000:
					print('\n Task Completed! \n')
					break
				print("Average over last 100 episode: {0:.2f} \n".format(is_solved))
		finally:
			straight_model.save_model()
			if agent != None:
				agent.destroy()
				time.sleep(1)
	return loss

# ==============================================================================
# -- Trains DQN agent only for right turn ------------------------------
# -- Scenario Right turn on Traffic Jnction ------------------------------------
# ==============================================================================
def train_right_DQN(episodes,agent):
	#Create model
	loss = []
	right_turn_model = md.DQN(4,4,'Right_Turn')
	for epi in range(episodes):
		try:
				#agent.reset(False)
				agent.reset(True)
				print(f'spawn suceeded----------')
				#Get the first state
				state = [50,90,0,0]
				state = np.reshape(state, (1,4))
				score = 0
				max_step = 1000
				for i in range(max_step):
					choice = right_turn_model.act(state)
					action = choose_action_rightturn(choice)
					print(f"action ------------------> {action}")
					next_state, reward, done, _ = agent.step_rightturn(action)
					print(f'obs----------->{next_state}-----reward--- {reward} -----done--{done}')
					time.sleep(0.5)
					score += reward
					next_state = np.reshape(next_state, (1, 4))
					right_turn_model.remember(state, choice, reward, next_state, done)
					state = next_state
					right_turn_model.replay(done,epi,loss)
					if done:
						print("episode: {}/{}, score: {}".format(epi, episodes, score))
						break
				loss.append(score)
				# Average score of last 100 episode
				is_solved = 0
				if len(loss)>=100:
					is_solved = np.mean(loss[-100:])
				if is_solved > 1000:
					print('\n Task Completed! \n')
					break
				print("Average over last 100 episode: {0:.2f} \n".format(is_solved))
		finally:
			right_turn_model.save_model()
			if agent != None:
				agent.destroy()
				time.sleep(1)
	return loss

# ==============================================================================
# -- Trains DQN agent only for LEFT TURN ------------------------------
# -- Scenario LEFT TURN on Traffic Jnction ------------------------------------
# ==============================================================================
def train_left_DQN(episodes,agent):
	#Create model
	loss = []
	left_turn_model = md.DQN(4,4,'Left_Turn')  #corrected from 2 to 3
	for epi in range(episodes):
		try:
				#agent.reset(False)
				agent.reset(True)
				traffic_light = None
				print(f'spawn suceeded----------')
				#Get the first state
				state = [50,90,0,0]
				state = np.reshape(state, (1,4))
				score = 0
				max_step = 200
				for i in range(max_step):
					choice = left_turn_model.act(state)
					action = choose_action_leftturn(choice)
					print(f"action ------------------> {action}")
					next_state, reward, done, _ = agent.step_leftturn(action)
					print(f'obs----------->{next_state}-----reward--- {reward} -----done--{done}')
					time.sleep(0.5)
					score += reward
					next_state = np.reshape(next_state, (1, 4))
					left_turn_model.remember(state, choice, reward, next_state, done)
					state = next_state
					left_turn_model.replay(done,epi,loss)
					if done:
						print("episode: {}/{}, score: {}".format(epi, episodes, score))
						break
				loss.append(score)
				# Average score of last 100 episode
				is_solved = 0
				if len(loss)>=100:
					is_solved = np.mean(loss[-100:])
				if is_solved > 800:
					print('\n Task Completed! \n')
					break
				print("Average over last 100 episode: {0:.2f} \n".format(is_solved))
		finally:
			left_turn_model.save_model()
			if agent != None:
				agent.destroy()
				time.sleep(1)
	return loss

# ==============================================================================
# -- Trains DQN agent only for left lane change ------------------------------
# -- Scenario Left lane chane ------------------------------------
# ==============================================================================
def train_left_lane_change(episodes,agent):
	#Create model
	loss = []
	left_lane_model = md.DQN(4,4,'Left_Lane')
	for epi in range(episodes):
		try:
				agent.reset(True)
				#State space normal distance y difference and x difference
				state = [5,5,5,5]
				state = np.reshape(state, (1,4))
				score = 0
				max_step = 1000
				for i in range(max_step):
					choice = left_lane_model.act(state)
					action = choose_action_leftlanechange(choice)
					next_state, reward, done, _ = agent.step_leftlanechange(action)
					time.sleep(0.1)
					score += reward
					next_state = np.reshape(next_state, (1, 4))
					left_lane_model.remember(state, choice, reward, next_state, done)
					state = next_state
					left_lane_model.replay(done,epi,loss)
					if done:
						print("episode: {}/{}, score: {}".format(epi, episodes, score))
						break
				loss.append(score)
				# Average score of last 100 episode
				is_solved = 0
				if len(loss)>=100:
					is_solved = np.mean(loss[-100:])
				if is_solved > 1200:
					print('\n Task Completed! \n')
					break
				print("Average over last 100 episode: {0:.2f} \n".format(is_solved))
		finally:
			left_lane_model.save_model()
			if agent != None:
				agent.destroy()
				time.sleep(10)
	return loss



# ==============================================================================
# -- Trains DQN agent only for right lane change ------------------------------
# -- Scenario RIGHT LANE CHANGE chane ------------------------------------
# ==============================================================================
def train_right_lane_change(episodes,agent):
	#Create model
	loss = []
	right_lane_model = md.DQN(4,4,'Right_Lane')
	for epi in range(episodes):
		try:
				agent.reset(True)
				#State space normal distance y difference and x difference
				state = [5,5,5,5]
				state = np.reshape(state, (1,4))
				score = 0
				max_step = 1000
				for i in range(max_step):
					choice = right_lane_model.act(state)
					action = choose_action_rightlanechange(choice)
					if(epi>=epi_count and epi_count<210):
						if(agent.lane_id_ego!=agent.lane_id_target and action[1]<0):
							action[1] =  0.21
							choice = 0
						elif agent.lane_id_ego==agent.lane_id_target:
							if(agent.yaw_vehicle>1):
								action[1] = -0.14
								choice = 1
					print(f"action 222------------------> {action}")
					next_state, reward, done, _ = agent.step_rightlanechange(action)
					time.sleep(0.1)
					score += reward
					next_state = np.reshape(next_state, (1, 4))
					right_lane_model.remember(state, choice, reward, next_state, done)
					state = next_state
					right_lane_model.replay(done,epi,loss)
					if done:
						print("episode: {}/{}, score: {}".format(epi, episodes, score))
						break
				loss.append(score)
				# Average score of last 100 episode
				is_solved = 0
				if len(loss)>=100:
					is_solved = np.mean(loss[-100:])
				if is_solved > 1050:
					print('\n Task Completed! \n')
					break
				print("Average over last 100 episode: {0:.2f} \n".format(is_solved))
		finally:
			right_lane_model.save_model()
			if agent != None:
				agent.destroy()
				time.sleep(1)
	return loss









# ==============================================================================
# -- Function trains DQN to achieve overall task ------------------------------
# -- Scenario Right turn on Traffic Jnction ------------------------------------
# ==============================================================================
def train_overall_dqn(episodes, agent):
	'''For comparison with RL agent 
	that learns the overall task'''
	#Create model
	loss = []
	overall_model = md.DQN(4,3,'Overall')
	for epi in range(episodes):
		try:
				#agent.reset(False)
				agent.reset(True)
				print(f'spawn suceeded----------')
				state = [0,50,0]
				state = np.reshape(state, (1,3))
				score = 0
				max_step = 100
				for i in range(max_step):
					choice = overall_model.act(state)
					action = choose_action_overall(choice)
					print(f"action ------------------> {action}")
					next_state, reward, done, _ = agent.step_overall(action)
					print(f'obs----------->{next_state}-----reward--- {reward} -----done--{done}')
					time.sleep(0.5)
					score += reward
					next_state = np.reshape(next_state, (1, 3))
					overall_model.remember(state, choice, reward, next_state, done)
					state = next_state
					overall_model.replay(done,epi,loss)
					if done:
						print("episode: {}/{}, score: {}".format(epi, episodes, score))
						break
				loss.append(score)
				# Average score of last 100 episode
				is_solved = 0
				if len(loss)>=100:
					is_solved = np.mean(loss[-100:])
				if is_solved > 500:
					print('\n Task Completed! \n')
					break
				print("Average over last 100 episode: {0:.2f} \n".format(is_solved))
		finally:
			overall_model.save_model()
			if agent != None:
				agent.destroy()
				time.sleep(5)
	return loss


# ==============================================================================
# -- Function trains Hierarchical DQN to achieve overall task ------------------
# -- Scenario Right turn on Traffic Jnction ------------------------------------
# ==============================================================================
def train_hierarchical_dqn(episodes, agent):
	'''For comparison with RL agent 
	that learns the overall task'''
	#Create model
	loss = []
	hierarchical_model = md.DQN(2,4,'Hierarchical')
	for epi in range(episodes):
		try:
				#agent.reset(False)
				subgoal_reached = False
				target_count = 0
				agent.reset(True)
				print(f'spawn suceeded----------')
				state = [0,100,90,0]
				state = np.reshape(state, (1,4))
				score = 0
				max_step = 250
				for i in range(max_step):
					choice = hierarchical_model.act(state)
					action = choose_action_hierarchical(choice)
					print(f"action ------------------> {action}")
					next_state, reward, done, subgoal_reached, _ = agent.step_hierarchical(action,target_count)
					if subgoal_reached:
						target_count = 1
					print(f'obs----------->{next_state}-----reward--- {reward} -----done--{done}----{target_count}-----{subgoal_reached}')
					time.sleep(0.3)
					score += reward
					next_state = np.reshape(next_state, (1, 4))
					hierarchical_model.remember(state, choice, reward, next_state, done)
					state = next_state
					hierarchical_model.replay(done,epi,loss)
					if done:
						print("episode: {}/{}, score: {}".format(epi, episodes, score))
						break
				loss.append(score)
				# Average score of last 100 episode
				is_solved = 0
				if len(loss)>=100:
					is_solved = np.mean(loss[-100:])
				if is_solved > 150:
					print('\n Task Completed! \n')
					break
				print("Average over last 100 episode: {0:.2f} \n".format(is_solved))
		finally:
			hierarchical_model.save_model()
			if agent != None:
				agent.destroy()
				time.sleep(5)
	return loss

# ==============================================================================
# -- NeuralNetworkControl ------------------------------------------------------
# -- Scenario Right turn on Traffic Jnction ------------------------------------
# -- Needs to be called from main ----------------------------------------------
# ==============================================================================
def nn_control():
	try:
		agent.reset(False)
		traffic_light = None
		straight_model = load_model('Straight_Model.h5')
		right_turn_model = load_model('Right_Turn_converged.h5')
		print(f'spawn suceeded----------')
		obs = [0,agent.get_location().x-19]
		while agent.get_location().x > 19:
			obs = np.reshape(obs, (1,2))
			choice = straight_model.predict(obs)
			action = choose_action_straight(np.argmax(choice[0]))
			obs, reward, done, _ = agent.step_straight(action)
			time.sleep(0.5)
			#Break if in traffic light trigger box
			if agent.get_vehicle().is_at_traffic_light():
				agent.step([0.0, 0.0, 1.0, False])
				#Stop at intersection
				traffic_light = agent.get_vehicle().get_traffic_light()
				break
		#Staye Stopped at traffic light
		agent.step([0.0, 0.0, 1.0, False])
		time.sleep(1)
		obs = [50,90]
		'''while(traffic_light.get_state() != carla.TrafficLightState.Green):
				print(traffic_light.get_state())'''
		done = False
		while(not done):
			obs = np.reshape(obs, (1,2))
			choice = right_turn_model.predict(obs)
			action = choose_action_rightturn(np.argmax(choice[0]))
			print(f'action-------------{action}')
			obs, reward, done, _ = agent.step_rightturn(action)
			print(f'obs----------->{obs}-----reward--- {reward} -----done--{done}')
			time.sleep(0.5)
		count = 0
		while count<10:
			print('Here')
			agent.step([0.5, 0.0, 0.0, False])
			time.sleep(0.5)
			count=count+1
		agent.step([0.0, 0.0, 1.0, False])
		time.sleep(5)
	finally:
		agent.destroy()
		time.sleep(5)

# ==============================================================================
# -- NeuralNetworkControl For Lane Change --------------------------------------
# -- Scenario Change Left Lane -------------------------------------------------
# -- Needs to be called from main ----------------------------------------------
# ==============================================================================
def nn_lane_change():
	try:
		agent.reset(False)
		left_lane_model = load_model('Left_LaneF.h5')
		print(f'spawn suceeded----------')
		next_state = [5,5,5,5]
		done = False
		while(not done):
			state = np.reshape(next_state, (1,4))
			choice = left_lane_model.predict(state)
			action = choose_action_leftlanechange(np.argmax(choice))
			print(f"action ------------------> {action}")
			next_state, reward, done, _ = agent.step_leftlanechange(action)
			time.sleep(0.1)
	finally:
		agent.destroy()
		time.sleep(5)


def nn_right_lane_change():
	try:
		agent.reset(False)
		right_lane_model = load_model('Right_Lane.h5')
		print(f'spawn suceeded----------')
		next_state = [5,5,5,5]
		done = False
		while(not done):
			state = np.reshape(next_state, (1,4))
			choice = right_lane_model.predict(state)
			action = choose_action_rightlanechange(np.argmax(choice))
			print(f"action ------------------> {action}")
			next_state, reward, done, _ = agent.step_rightlanechange(action)
			time.sleep(0.1)
	finally:
		agent.destroy()
		time.sleep(5)




# ==============================================================================
# -- Manual Control ------------------------------------------------------------
# -- Scenario Right turn on Traffic Jnction ------------------------------------
# -- Needs to be called from main ----------------------------------------------
# ==============================================================================
def manual_control():
	try:
		agent.reset(False)
		traffic_light = None
		print(f'spawn suceeded----------')
		while agent.get_location().x > 19:
			obs, reward, done, _  = agent.step_overall([0.6, 0.0, 0.0, False])
			#print(f'obs----------->{obs}-----reward--- {reward} -----done--{done}')
			time.sleep(0.5)
			#Break if in traffic light trigger box
			if agent.get_vehicle().is_at_traffic_light():
				agent.step([0.0, 0.0, 1.0, False])
				#Stop at intersection
				traffic_light = agent.get_vehicle().get_traffic_light()
				break
		#Staye Stopped at traffic light
		agent.step([0.0, 0.0, 1.0, False])
		time.sleep(1)
		while(traffic_light.get_state() != carla.TrafficLightState.Green):
				print(traffic_light.get_state())
		print(f'Location========================={agent.get_vehicle().get_location()}')
		while(agent.get_location().y > 115):
			obs, reward, done, _  = agent.step_overall([0.5, 0.2, 0.0, False])
			#print(f'obs----------->{obs}-----reward--- {reward} -----done--{done}')
			time.sleep(0.5)
		count = 0
		while count<10:
			print('Here')
			agent.step([0.5, 0.0, 0.0, False])
			time.sleep(0.5)
			count=count+1
		agent.step([0.0, 0.0, 1.0, False])
		time.sleep(5)
	finally:
		agent.destroy()
		time.sleep(5)

#Test Code
def lane_control():
	try:
		agent.reset(False)
		while(agent.map.get_waypoint(agent.vehicle.get_location()).lane_id != agent.next_lane_target.lane_id):
			print(f'location1-----------{agent.get_location()}')
			obs, reward, done, _  = agent.step_leftlanechange([0.6, -0.15, 0.0, False])
			print(f'obs----------->{obs}-----reward==== {reward} -----done--{done}')
			time.sleep(0.1)
		yaw_vehicle = agent.vehicle.get_transform().rotation.yaw
		yaw_target_road = agent.next_lane_target.transform.rotation.yaw
		while(abs(abs(int(179+yaw_vehicle))-abs(int(yaw_target_road)))>1):
			yaw_vehicle = agent.vehicle.get_transform().rotation.yaw
			print(f'location2-----------{agent.get_location()}')
			obs, reward, done, _  = agent.step_leftlanechange([0.6, 0.2, 0.0, False])
			print(f'obs----------->{obs}-----reward==== {reward} -----done--{done}')
			time.sleep(0.1)
		obs, reward, done, _  = agent.step_leftlanechange([0.0, 0.0, 1.0, False])
		time.sleep(0.5)
	finally:
		agent.destroy()
		time.sleep(5)


def right_lane_control():
	try:
		agent.reset(False)
		while(agent.map.get_waypoint(agent.vehicle.get_location()).lane_id != agent.next_lane_target.lane_id):
			print(f'location1-----------{agent.get_location()}')
			obs, reward, done, _  = agent.step_rightlanechange([0.5, 0.23, 0.0, False])
			print(f'obs----------->{obs}-----reward==== {reward} -----done--{done}')
			time.sleep(0.1)
		yaw_vehicle = agent.vehicle.get_transform().rotation.yaw
		yaw_target_road = agent.next_lane_target.transform.rotation.yaw
		while(yaw_vehicle>1):
			print(f'yaw-----{yaw_vehicle}---diff------------->>>>>{yaw_vehicle-yaw_target_road}')
			yaw_vehicle = agent.vehicle.get_transform().rotation.yaw
			print(f'location2-----------{agent.get_location()}')
			obs, reward, done, _  = agent.step_rightlanechange([0.5, -0.14, 0.0, False])
			print(f'obs----------->{obs}-----reward==== {reward} -----done--{done}')
			time.sleep(0.1)
		obs, reward, done, _  = agent.step_rightlanechange([0.0, 0.0, 1.0, False])
		time.sleep(0.5)
	finally:
		agent.destroy()
		time.sleep(5)


def left_turn():
	try:
		agent.reset(False)
		norm = 100
		while(norm>=1.8):
			obs, reward, done, _  = agent.step_leftturn([0.5, -0.2, 0.0, False])
			norm = obs[0]
			print(f'obs----------->{obs}-----reward--- {reward} -----done--{done}')
			time.sleep(0.1)
		time.sleep(0.5)
	finally:
		agent.destroy()
		time.sleep(5)
		



# ==============================================================================
# -- Manual Method------------------------------------------------------------
# -- Call function train_agent_name(episodes,agent) to train ------------------
# -- Call function manual_control() to see the task ---------------------------
# -- Call function nn_control() to test the nn agents --------------------------
# ==============================================================================
if __name__ == '__main__':
	"""
	Main function
	"""
	agent = env.CarlaVehicle()
	#Code to train the models
	episodes = 500
	loss = train_hierarchical_dqn(episodes,agent)
	ut.plot(loss)

	#nn_lane_change()
	#Code for Manual Control
	#manual_control()
	#lane_control()
	#left_turn()
	#right_lane_control()
	#nn_right_lane_change()

