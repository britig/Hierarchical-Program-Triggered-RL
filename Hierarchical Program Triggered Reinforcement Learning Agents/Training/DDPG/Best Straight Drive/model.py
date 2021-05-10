''' 
Deep Deterministic Policy Gradient implementation 
Class DDPG contains hyperparameter and type initialisations
'''

import random
import matplotlib.pyplot as plt
from keras.callbacks import TensorBoard
import tensorflow as tf
import time
import numpy as np
from nn_actor_critic import FeedForwardNN
import torch
from torch import nn
from torch.optim import Adam

#Integrating tensorboard
from torch.utils.tensorboard import SummaryWriter


MODEL_NAME = '2X64'
np.random.seed(32)
random.seed(32)


# Own Tensorboard class for logging
class ModifiedTensorBoard(TensorBoard):
	# Overriding init to set initial step and writer (we want one log file for all .fit() calls)
	def __init__(self, **kwargs):
		super().__init__(**kwargs)
		self.step = 1
		self.writer = tf.summary.create_file_writer(self.log_dir)

	# Overriding this method to stop creating default log writer
	def set_model(self, model):
		pass

	# Overrided, saves logs with our step number
	# (otherwise every .fit() will start writing from 0th step)
	def on_epoch_end(self, epoch, logs=None):
		self.update_stats(**logs)

	# Overrided
	# We train for one batch only, no need to save anything at epoch end
	def on_batch_end(self, batch, logs=None):
		pass

	# Overrided, so won't close writer
	def on_train_end(self, _):
		pass

	# Custom method for saving own metrics
	# Creates writer, writes custom metrics and closes writer
	def update_stats(self, **stats):
		self._write_logs(stats, self.step)	

	def _write_logs(self, logs, index):
		with self.writer.as_default():
			for name, value in logs.items():
				tf.summary.scalar(name, value[1], step=index)
				self.step += 1
				self.writer.flush()



class DDPG:

	""" input : discrete actions, state space, type of learning(Straight/left/right)"""
	def __init__(self, action_space, state_space, radar_dim, type):
		self.action_space = action_space
		self.state_space = state_space
		self.radar_space = radar_dim
		self.lower_bound = 0.0
		self.upper_bound = 1.0 # Throtle limit
		self.epsilon = 0.8
		self.gamma = .99
		self.batch_size = 128
		self.epsilon_min = .1
		# self.lr = 0.01
		self.epsilon_decay = .997

		self.critic_lr = 0.007
		self.actor_lr = 0.007

		# Custom tensorboard object
		now = time.localtime()
		self.tensorboard = ModifiedTensorBoard(log_dir=f"logs/{MODEL_NAME}Jan_{now.tm_mday}_{now.tm_min}_{now.tm_hour}_{self.radar_space}_{self.actor_lr}_{self.batch_size}")
		self.type = type

		# Networks
		# we need to share some weights in between actor <--> critic 
		# that we will do after every update
		self.actor = FeedForwardNN(self.radar_space, self.state_space, self.action_space, "actor")
		self.critic = FeedForwardNN(self.radar_space, self.state_space, 1, "critic")

		# Target model this is what we .predict against every step
		self.target_update_counter = 0
		self.target_actor = self.actor
		self.target_critic = self.critic

		# We use different np.arrays for each tuple element for replay memory
		self.buffer_capacity=50_000
		self.buffer_counter = 0;
		self.state_buffer = np.zeros((self.buffer_capacity, self.state_space))
		self.action_buffer = np.zeros((self.buffer_capacity, self.action_space))
		self.reward_buffer = np.zeros((self.buffer_capacity, 1))
		self.next_state_buffer = np.zeros((self.buffer_capacity, self.state_space))
		self.radar_buffer = np.zeros((self.buffer_capacity, self.radar_space))
		self.next_radar_buffer = np.zeros((self.buffer_capacity, self.radar_space))
		
		self.t_so_far = 0
		now = time.localtime()
		self.writer = SummaryWriter(log_dir=f"runs/Jan_{now.tm_mday}_{now.tm_min}_{now.tm_hour}_{self.radar_space}_{self.actor_lr}_{self.batch_size}")


	# Takes (s,a,r,s') obervation tuple as input
	def remember(self,radar_state, radar_state_next, state, action, reward, next_state, done=None):
		# Set index to zero if buffer_capacity is exceeded,
		# replacing old records
		index = self.buffer_counter % self.buffer_capacity

		self.radar_buffer[index] = radar_state
		self.next_radar_buffer[index] = radar_state_next
		self.state_buffer[index] = state
		self.action_buffer[index] = action
		self.reward_buffer[index] = reward
		self.next_state_buffer[index] = next_state

		self.buffer_counter += 1


	# policy() returns an action sampled from our Actor network plus 
	# some noise for exploration.
	def policy(self, radar_state, physical_state):
		# .squeeze() function returns a tensor with the same value as its first 
		# argument, but a different shape. It removes dimensions whose size is one. 
		if np.random.rand() <= self.epsilon:
			sampled_actions = torch.rand(1)

		else:
			sampled_actions = self.actor(radar_state, physical_state, None)
			sampled_actions = sampled_actions.detach().numpy()
			sampled_actions = np.array([(x+1)/2 for x in sampled_actions])

		if self.epsilon > self.epsilon_min:
			self.epsilon *= self.epsilon_decay

	    # We make sure action is within bounds
	    # Clip (limit) the values in an array here b/w lower and upper bound
		legal_action = np.clip(sampled_actions, self.lower_bound, self.upper_bound)
		return np.squeeze(legal_action)


	# We compute the loss and update parameters (learn)
	def replay(self):
		# Get sampling range 
		record_range = min(self.buffer_counter, self.buffer_capacity)
		# Randomly sample indices(batch)
		batch_indices = np.random.choice(record_range, self.batch_size)

		# Convert to tensors
		state_batch = torch.tensor(self.state_buffer[batch_indices], dtype=torch.float)
		action_batch = torch.tensor(self.action_buffer[batch_indices], dtype=torch.float)
		reward_batch = torch.tensor(self.reward_buffer[batch_indices], dtype=torch.float)
		next_state_batch = torch.tensor(self.next_state_buffer[batch_indices], dtype=torch.float)
		radar_batch = torch.tensor(self.radar_buffer[batch_indices], dtype=torch.float)
		next_radar_batch = torch.tensor(self.next_radar_buffer[batch_indices], dtype=torch.float)

		'''
		# Training and updating Actor & Critic Networks
		# Gradient Tape tracks the automatic differentiation that occurs in a TF model.
		with tf.GradientTape() as tape:
			target_actions = self.target_actor([next_state_batch, next_radar_batch])
			y = reward_batch + self.gamma * self.target_critic([next_state_batch, next_radar_batch, target_actions])
			critic_value = self.critic([state_batch, radar_batch, action_batch])
			critic_loss = tf.math.reduce_mean(tf.math.square(y - critic_value))

		critic_grad = tape.gradient(critic_loss, self.critic.trainable_variables)
		self.critic_optimizer.apply_gradients(
			zip(critic_grad, self.critic.trainable_variables)
			)

		with tf.GradientTape() as tape:
			actions = self.actor([state_batch, radar_batch])
			critic_value = self.critic([state_batch, radar_batch, actions])
			# Used `-value` as we want to maximize the value given
			# by the critic for our actions
			actor_loss = -tf.math.reduce_mean(critic_value)

		actor_grad = tape.gradient(actor_loss, self.actor.trainable_variables)
		self.actor_optimizer.apply_gradients(
			zip(actor_grad, self.actor.trainable_variables)
		)
		'''

		"""
		``````````````````````````````````````````````````````````````````````````
		# We are missing one more step
		# We got to match some preprocess layers of actor and critic
		# Create a function and call in between the above and here too
		``````````````````````````````````````````````````````````````````````````
		"""
	
		# Setting the Actor and Critic common shared layer as mean of both
		tau = 0.001
		new_dict = dict(self.critic.named_parameters())
		for name, param in self.actor.named_parameters():
			if 'layer' in name:
				new_dict[name] = (tau*param.data + (1-tau)*new_dict[name])/2

		# old_dict = dict(self.critic.named_parameters())
		self.critic.load_state_dict(new_dict)

		new_dict = dict(self.actor.named_parameters())
		for name, param in self.critic.named_parameters():
			if 'layer' in name:
				new_dict[name] = (tau*param.data + (1-tau)*new_dict[name])/2

		self.actor.load_state_dict(new_dict)


		# Critic Network
		target_actions = self.target_actor(next_radar_batch, next_state_batch, None)
		y = reward_batch + self.gamma * self.target_critic(next_radar_batch, next_state_batch, target_actions)
		critic_value = self.critic(radar_batch, state_batch, action_batch)
		critic_loss = torch.mean((y-critic_value)**2)

		critic_optimizer = Adam(self.critic.parameters(), lr=self.critic_lr)
		critic_optimizer.zero_grad()
		critic_loss.backward()
		critic_optimizer.step()

		# Actor Network
		actions = self.actor(radar_batch, state_batch, None)
		critic_value = self.critic(radar_batch, state_batch, action_batch)
		actor_loss = -torch.mean(critic_value)

		actor_optimizer = Adam(self.actor.parameters(), lr=self.actor_lr)
		actor_optimizer.zero_grad()
		actor_loss.backward()
		actor_optimizer.step()

		return actor_loss.detach().numpy(), critic_loss.detach().numpy()


	# This update target parameters slowly
	# Based on rate `tau`, which is much less than one ~0.001 order
	# This also logs the historgrams

	def update_target(self, tau, val):
		if(tau<1):
			new_dict = dict(self.target_critic.named_parameters())
			for name, param in self.critic.named_parameters():
			    new_dict[name].data = (param.data * tau + new_dict[name].data * (1 - tau))

			self.target_critic.load_state_dict(new_dict)

			new_dict = dict(self.target_actor.named_parameters())
			for name, param in self.actor.named_parameters():
			    new_dict[name].data = (param.data * tau + new_dict[name].data * (1 - tau))

			self.target_actor.load_state_dict(new_dict)

		else:
			self.target_critic.load_state_dict(self.critic.state_dict())
			self.target_actor.load_state_dict(self.actor.state_dict())

		if val%25==0 and  tau==0.01:
		# Log the histogram data of the Actor/Critic Network
			for name, param in self.actor.named_parameters():
				if 'weight' in name:
					self.writer.add_histogram("actor"+name, param.detach().numpy(), self.t_so_far)

			for name, param in self.critic.named_parameters():
				if 'weight' in name:
					self.writer.add_histogram("critic"+name, param.detach().numpy(), self.t_so_far)

			self.t_so_far += 1


	def save_model(self):
		# serialize weights to HDF5
		print("---Saved modelweights to disk---")
		# Save the weights
		torch.save(self.actor.state_dict(), str(self.type) + "_DDPGactor.pth")
		torch.save(self.critic.state_dict(), str(self.type) + "_DDPGcritic.pth")

		torch.save(self.target_actor.state_dict(), str(self.type) + "_target_actor.pth")
		torch.save(self.target_critic.state_dict(), str(self.type) + "_target_critic.pth")

