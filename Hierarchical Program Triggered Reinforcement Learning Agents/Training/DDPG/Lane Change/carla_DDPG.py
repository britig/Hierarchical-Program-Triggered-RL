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
from keras.models import load_model
import matplotlib.pyplot as plt 

np.random.seed(32)
random.seed(32)
AGGREGATE_STATS_EVERY = 100
ROUNDING_FACTOR = 2

try:
	sys.path.append(glob.glob('../../../carla/dist/carla-*%d.%d-%s.egg' % (
		sys.version_info.major,
		sys.version_info.minor,
		'win-amd64' if os.name == 'nt' else 'linux-x86_64'))[0])
except IndexError:
	pass
import carla


#action space for right turn
def choose_action_lane_change(choice):
	action = []
	action = [0.5, float(choice), 0, False]
	return action


# ==============================================================================
# -- Function Lane Change DDPG Network ------------------
# -- Scenario Lane Change on Traffic Jnction ------------------------------------
# ==============================================================================
def train_left_lane_change_DDPG(episodes,agent):
	# Two action choice for output
	# amount of acceleration of straight vehicle
	# Shape is the number of neural inputs or output
	action_space = 1
	state_space = 5

	radar_space = 500
	
	# Get the first state (speed, distance from junction)
	# Create model
	leftLaneChange_model = md.DDPG(action_space, state_space, radar_space, 'Lane_Change_Model')

	# Update rate of target
	tau = 0.005

	# To store reward history of each episode
	ep_reward_list = []
	# To store average reward history of last few episodes
	avg_reward_list = []
	# To store actor and critic loss
	actor_loss = []
	critic_loss = []

	for epi in range(episodes):
		try:
			loc = random.randint(30, 130)
			print(f'--------Spawn Succeded Lane Change-----------')
			radar_state_prev = agent.reset(True, loc)
			radar_state_prev = np.reshape(radar_state_prev, (1,radar_space))
			start_state = [0, 0, 0, 0, 19]
			state = np.reshape(start_state, (1,state_space))
			score = 0
			max_step = 5_00

			actor_loss_epi = []
			critic_loss_epi = []
			for i in range(max_step):
				choice = leftLaneChange_model.policy(radar_state_prev, state)
				action = choose_action_lane_change(choice)
				
				print(f'action----{action}-------epsilon----{leftLaneChange_model.epsilon}')
				radar_state_next, next_state, reward, done, _ = agent.left_lane_change(action)
				time.sleep(0.2)

				score += reward
				next_state = np.reshape(next_state, (1, state_space))
				leftLaneChange_model.remember(radar_state_prev, radar_state_next, state, choice, reward, next_state, done)
				state = next_state
				radar_state_prev = np.reshape(radar_state_next, (1, radar_space))

				# This is back-prop, updating weights
				lossActor, lossCritic = leftLaneChange_model.replay()
				actor_loss_epi.append(lossActor)
				critic_loss_epi.append(lossCritic)

				# Update the target model, we do it slowly as it keep things stable, SOFT VERSION
				leftLaneChange_model.update_target(tau, 1)
				if done:
					break

			actor_loss.append(np.mean(actor_loss_epi))
			critic_loss.append(np.mean(critic_loss_epi))

			# Will do a HARD update now, setting it to critic and actor, set tau=1
			leftLaneChange_model.update_target(0.001, epi)

			ep_reward_list.append(score)
			print("\nepisode: {}/{}, score: {}".format(epi, episodes, score))

			avg_reward = np.mean(ep_reward_list[-AGGREGATE_STATS_EVERY:])
			print("\nEpisode * {} * Avg Reward is ==> {}\n".format(epi, avg_reward))
			avg_reward_list.append(avg_reward)

			# Update log stats (every given number of episodes)
			min_reward = min(ep_reward_list[-AGGREGATE_STATS_EVERY:])
			max_reward = max(ep_reward_list[-AGGREGATE_STATS_EVERY:])
			# straight_model.tensorboard.update_stats(reward_avg=avg_reward, reward_min=min_reward, reward_max=max_reward, epsilon=straight_model.epsilon)
			leftLaneChange_model.tensorboard.update_stats(reward_avg=avg_reward, critic_loss=np.mean(critic_loss_epi), actor_loss=np.mean(actor_loss_epi))
			
			if(epi%500==0 and epi>1):
				x_label = 'Episodes'
				y_label = 'Actor Loss'
				ut.plot(actor_loss, x_label, y_label, epi)
				y_label = 'Critic Loss'
				ut.plot(critic_loss,  x_label, y_label, epi)
				time.sleep(1)

			# # Average score of last 100 episode
			# if avg_reward > 500:
			# 	print('\n Task Completed! \n')
			# 	break

		finally:
			print(f"Task Completed! Episode {epi}")

			leftLaneChange_model.save_model()
			if agent != None:
				agent.destroy()
				time.sleep(2)

	return actor_loss, critic_loss


if __name__ == '__main__':
	"""
	Main function
	"""
	agent = env.CarlaVehicle()

	#Code to train the models
	episodes = 5_000
	# actor_Loss, critic_Loss = train_straight_DDPG(episodes,agent)
	actor_Loss, critic_Loss = train_left_lane_change_DDPG(episodes,agent)

	print("\n\n--We need to Maxmise Actor Loss--Minimise Critic Loss--\n\n")
	x_label = 'Episodes'
	y_label = 'Actor Loss'
	ut.plot(actor_Loss, x_label, y_label)
	y_label = 'Critic Loss'
	ut.plot(critic_Loss,  x_label, y_label)
	#Code for Manual Control
	#manual_control()

