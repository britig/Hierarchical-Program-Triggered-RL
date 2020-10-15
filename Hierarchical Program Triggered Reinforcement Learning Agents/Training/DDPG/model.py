''' 
Deep Deterministic Policy Gradient implementation 
Class DDPG contains hyperparameter and type initialisations
'''

import random
from tensorflow.keras import layers
import matplotlib.pyplot as plt
from keras.callbacks import TensorBoard
import tensorflow as tf
import time
import numpy as np

MODEL_NAME = 'Right_Turn_ModelDDPG'
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
				tf.summary.scalar(name, value, step=index)
				self.step += 1
				self.writer.flush()


class DDPG:

	""" input : discrete actions, state space, type of learning(Straight/left/right)"""
	def __init__(self, action_space, state_space, radar_dim, type):
		self.action_space = action_space
		self.state_space = state_space
		self.radar_space = radar_dim
		self.lower_bound = -0.3
		self.upper_bound = 0.3 # Steer limit
		self.epsilon = 0.8
		self.gamma = .99
		self.batch_size = 64
		self.epsilon_min = .1
		# self.lr = 0.01
		self.epsilon_decay = .997

		self.critic_lr = 0.003
		self.actor_lr = 0.003

		self.critic_optimizer = tf.keras.optimizers.Adam(self.critic_lr)
		self.actor_optimizer = tf.keras.optimizers.Adam(self.actor_lr)

		# Setting all layers to float32
		tf.keras.backend.set_floatx('float32')
		self.radar_input, self.state_input, self.state_concat = self.__process_state()
		self.actor = self.get_actor()
		self.critic = self.get_critic()

		# Custom tensorboard object
		self.tensorboard = ModifiedTensorBoard(log_dir="logs/{}-{}-{}-{}".format(MODEL_NAME, int(time.time()), self.actor_lr, self.critic_lr))
		self.type = type

		# Target model this is what we .predict against every step
		self.target_update_counter = 0
		self.target_actor = self.get_actor()
		self.target_critic = self.get_critic()
		self.target_actor.set_weights(self.actor.get_weights())
		self.target_critic.set_weights(self.critic.get_weights())

		# We use different np.arrays for each tuple element for replay memory
		self.buffer_capacity=50_000
		self.buffer_counter = 0
		self.state_buffer = np.zeros((self.buffer_capacity, self.state_space))
		self.action_buffer = np.zeros((self.buffer_capacity, self.action_space))
		self.reward_buffer = np.zeros((self.buffer_capacity, 1))
		self.next_state_buffer = np.zeros((self.buffer_capacity, self.state_space))
		self.radar_buffer = np.zeros((self.buffer_capacity, self.radar_space))
		self.next_radar_buffer = np.zeros((self.buffer_capacity, self.radar_space))
		

	# Now we will define Actor and Critic Networks
	'''
	We need the initialization for last layer of the Actor, this prevents us 
	from getting 1 or -1 output values in the initial stages, which would 
	squash our gradients to zero, as we use the tanh activation.
	'''
	def __process_state(self):
		# Radar Data as input
		radar_input = layers.Input(shape=(self.radar_space))
		radar_out1 = layers.Dense(512, activation="relu")(radar_input)
		radar_out2 = layers.BatchNormalization()(radar_out1)
		radar_out3 = layers.Dense(256, activation="relu")(radar_out2)
		radar_out4 = layers.BatchNormalization()(radar_out3)
		radar_out5 = layers.Dense(256, activation="relu")(radar_out4)
		radar_out6 = layers.BatchNormalization()(radar_out5)

		#Physical State data as input 
		state_input = layers.Input(shape=(self.state_space))
		state_out1 = layers.Dense(4, activation="relu")(state_input)
		state_out2 = layers.BatchNormalization()(state_out1)
		state_out3 = layers.Dense(16, activation="relu")(state_out2)
		state_out4 = layers.BatchNormalization()(state_out3)

		# Both state(Radar and Physical) are treated different till now
		# and passed through seperate layer before concatenating
		state_concat = layers.Concatenate()([state_out4, radar_out6])

		return radar_input, state_input, state_concat

	def get_actor(self):
		# Initialize weights
		last_init = tf.random_uniform_initializer(minval=-0.005, maxval=0.005)
		
		concat_out1 = layers.Dense(256, activation="relu")(self.state_concat)
		concat_out2 = layers.BatchNormalization()(concat_out1)
		concat_out3 = layers.Dense(128, activation="relu")(concat_out2)
		concat_out4 = layers.BatchNormalization()(concat_out3)

		outputs = layers.Dense(self.action_space, activation="tanh", kernel_initializer=last_init)(concat_out4)
		# As it outputs the action

		outputs = (self.upper_bound + self.lower_bound)/2 + outputs*(self.upper_bound - self.lower_bound)/2
		model = tf.keras.Model([self.state_input, self.radar_input], outputs)
		return model


	def get_critic(self):
		# Initialize weights
		last_init = tf.random_uniform_initializer(minval=-0.005, maxval=0.005)

		# Action as input
		action_input = layers.Input(shape=(self.action_space))
		# action_out0 = layers.Dense(4, activation="relu")(action_input)
		action_out1 = layers.BatchNormalization()(action_input)

		# Both are passed through seperate layer before concatenating
		concat = layers.Concatenate()([self.state_concat, action_out1])

		out1 = layers.Dense(256, activation="relu")(concat)
		out2 = layers.BatchNormalization()(out1)
		out3 = layers.Dense(128, activation="relu")(out2)
		out4 = layers.BatchNormalization()(out3)

		outputs = layers.Dense(1, activation="linear", kernel_initializer=last_init)(out4)
		# Critic Outputs the Q values, it uses no activation, we use its raw value or Linear

		# Outputs single value for give state-action
		model = tf.keras.Model([self.state_input, self.radar_input, action_input], outputs)
		return model


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
			sampled_actions = random.uniform(self.lower_bound,self.upper_bound)

		else:
			sampled_actions = tf.squeeze(self.actor([physical_state, radar_state]))

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
		state_batch = tf.convert_to_tensor(self.state_buffer[batch_indices])
		action_batch = tf.convert_to_tensor(self.action_buffer[batch_indices])
		reward_batch = tf.convert_to_tensor(self.reward_buffer[batch_indices])
		reward_batch = tf.cast(reward_batch, dtype=tf.float32)
		next_state_batch = tf.convert_to_tensor(self.next_state_buffer[batch_indices])
		radar_batch = tf.convert_to_tensor(self.radar_buffer[batch_indices])
		next_radar_batch = tf.convert_to_tensor(self.next_radar_buffer[batch_indices])

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

		#gradiend is made to decrease thus applying '-' will make it to increase
		actor_grad = tape.gradient(actor_loss, self.actor.trainable_variables)
		self.actor_optimizer.apply_gradients(
			zip(actor_grad, self.actor.trainable_variables)
		)

		#actor_loss will increase gradulally...thus - values 
		return -actor_loss, critic_loss


	# This update target parameters slowly
	# Based on rate `tau`, which is much less than one.
	def update_target(self, tau):
		if(tau<1):
			new_weights = []
			target_variables = self.target_critic.weights
			for i, variable in enumerate(self.critic.weights):
				new_weights.append(variable * tau + target_variables[i] * (1 - tau))

			self.target_critic.set_weights(new_weights)

			new_weights = []
			target_variables = self.target_actor.weights
			for i, variable in enumerate(self.actor.weights):
			    new_weights.append(variable * tau + target_variables[i] * (1 - tau))

			self.target_actor.set_weights(new_weights)

		else:
			self.target_critic.set_weights(self.critic.get_weights())
			self.target_actor.set_weights(self.actor.get_weights())


	def save_model(self):
		# serialize weights to HDF5
		print("---Saved modelweights to disk---")
		# Save the weights
		self.actor.save_weights(str(self.type) + "_DDPGactor.h5")
		self.critic.save_weights(str(self.type) + "_DDPGcritic.h5")

		self.target_actor.save_weights(str(self.type) + "_target_actor.h5")
		self.target_critic.save_weights(str(self.type) + "_target_critic.h5")

