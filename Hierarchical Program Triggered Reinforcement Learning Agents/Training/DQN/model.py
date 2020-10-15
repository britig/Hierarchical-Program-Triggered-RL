''' Deep Q Learning implementation 
Class DQN contains hyperparameter and type initialisations
Author : Briti Gangopadhyay
Project : Program Controlled HRL
'''


import random
from keras import Sequential
from collections import deque
from keras.layers import Dense, Dropout, Conv2D, MaxPooling2D, Activation, Flatten
from keras.optimizers import Adam
import matplotlib.pyplot as plt
from keras.activations import relu, linear
from keras.callbacks import TensorBoard
import tensorflow as tf
import time
import numpy as np

np.random.seed(32)
random.seed(32)

IM_WIDTH = 640
IM_HEIGHT = 480
MODEL_NAME = '1X64X32X001_Hierarchical'
MIN_REPLAY_MEMORY_SIZE = 1_000
UPDATE_TARGET_EVERY = 4 
PREDICTION_BATCH_SIZE = 1
AGGREGATE_STATS_EVERY = 10

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


class DQN:

	""" input : discrete actions, state space, type of learning"""

	def __init__(self, action_space, state_space, type):

		self.action_space = action_space
		self.state_space = state_space
		self.epsilon = 0.8
		self.gamma = .99
		self.batch_size = 64
		self.epsilon_min = .01
		self.lr = 0.001
		self.epsilon_decay = .995
		self.memory = deque(maxlen=1000000)
		self.first_layer = 32
		self.second_layer = 16
		self.model = self.build_model()
		# Custom tensorboard object
		self.tensorboard = ModifiedTensorBoard(log_dir="logs/{}-{}".format(MODEL_NAME, int(time.time())))

		# Used to count when to update target network with main network's weights
		#self.target_update_counter = 0
		#self.graph = tf.get_default_graph()

		self.terminate = False
		self.last_logged_episode = 0
		self.training_initialized = False

		# Target model this is what we .predict against every step
		self.target_update_counter = 0
		self.target_model = self.build_model()
		self.target_model.set_weights(self.model.get_weights())
		self.type = type

	def build_model(self):

		model = Sequential()	
		model.add(Dense(self.first_layer, input_dim=self.state_space, activation=relu))
		model.add(Dense(self.second_layer, activation=relu))
		model.add(Dense(self.action_space, activation=linear))
		model.compile(loss="mse", optimizer=Adam(lr=self.lr), metrics=['accuracy'])
		return model

	def remember(self, state, action, reward, next_state, done):
		self.memory.append((state, action, reward, next_state, done))

	def act(self, state):

		if np.random.rand() <= self.epsilon:
			action = random.randrange(self.action_space)
			return action
		act_values = self.model.predict(state)
		print("act_values: ", act_values)
		print("act_values max: ", np.argmax(act_values[0]))
		return np.argmax(act_values[0])

	def replay(self,terminal_state,episode,ep_rewards):

		# Start training only if certain number of samples is already saved
		if len(self.memory) < self.batch_size:
			return

		# Get current states from minibatch, then query NN model for Q values
		minibatch = random.sample(self.memory, self.batch_size)

		states = np.array([i[0] for i in minibatch])
		actions = np.array([i[1] for i in minibatch])
		rewards = np.array([i[2] for i in minibatch])
		next_states = np.array([i[3] for i in minibatch])
		dones = np.array([i[4] for i in minibatch])

		states = np.squeeze(states)
		next_states = np.squeeze(next_states)

		targets = rewards + self.gamma*(np.amax(self.target_model.predict_on_batch(next_states), axis=1))*(1-dones)
		targets_full = self.model.predict_on_batch(states)
		ind = np.array([i for i in range(self.batch_size)])
		targets_full[[ind], [actions]] = targets

		

		self.model.fit(states, targets_full, batch_size=self.batch_size, epochs=1, verbose=0, shuffle=False)


		# Update target network counter every episode
		if terminal_state:
			self.target_update_counter += 1

		# If counter reaches set value, update target network with weights of main network
		if self.target_update_counter > UPDATE_TARGET_EVERY:
			self.target_model.set_weights(self.model.get_weights())
			self.target_update_counter = 0

		#Log in tensorboard
		if (not episode % AGGREGATE_STATS_EVERY or episode == 1) and (len(ep_rewards[-AGGREGATE_STATS_EVERY:])!=0):
				average_reward = sum(ep_rewards[-AGGREGATE_STATS_EVERY:])/len(ep_rewards[-AGGREGATE_STATS_EVERY:])
				min_reward = min(ep_rewards[-AGGREGATE_STATS_EVERY:])
				max_reward = max(ep_rewards[-AGGREGATE_STATS_EVERY:])
				self.tensorboard.update_stats(reward_avg=average_reward, reward_min=min_reward, reward_max=max_reward, epsilon=self.epsilon)


		if self.epsilon > self.epsilon_min:
			self.epsilon *= self.epsilon_decay

		'''#print(f'minibatch ----------{np.array([i[0] for i in minibatch])}')
		current_states = np.array([i[0] for i in minibatch])/255
		current_qs_list = self.model.predict(current_states, PREDICTION_BATCH_SIZE)

		# Get future states from minibatch, then query NN model for Q values
		# When using target network, query it, otherwise main network should be queried
		new_current_states = np.array([i[3] for i in minibatch])/255
		future_qs_list = self.target_model.predict(new_current_states, PREDICTION_BATCH_SIZE)

		X = []
		y = []

		#Now we need to enumerate our batches
		for index, (current_state, action, reward, new_current_state, done) in enumerate(minibatch):
			# If not a terminal state, get new q from future states, otherwise set it to 0
			# almost like with Q Learning, but we use just part of equation here
			if not done:
				max_future_q = np.max(future_qs_list[index])
				new_q = reward + self.gamma * max_future_q
			else:
				new_q = reward

			# Update Q value for given state
			current_qs = current_qs_list[index]
			current_qs[action] = new_q

			# And append to our training data
			X.append(current_state)
			y.append(current_qs)

		# Fit on all samples as one batch, log only on terminal state
		self.model.fit(np.array(X)/255, np.array(y), batch_size=self.batch_size, verbose=0, shuffle=False)

		# Update target network counter every episode
		if terminal_state:
			self.target_update_counter += 1

		# If counter reaches set value, update target network with weights of main network
		if self.target_update_counter > UPDATE_TARGET_EVERY:
			self.target_model.set_weights(self.model.get_weights())
			self.target_update_counter = 0

		if self.epsilon > self.epsilon_min:
			self.epsilon *= self.epsilon_decay'''

	def save_model(self):
		# serialize weights to HDF5
		self.model.save(str(self.type)+".h5")
		print("Saved model to disk")