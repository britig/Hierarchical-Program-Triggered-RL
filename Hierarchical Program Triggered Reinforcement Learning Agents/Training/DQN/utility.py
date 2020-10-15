''' Utility module containing 
functions for plotting etc
Author : Briti Gangopadhyay
Project : Program Controlled HRL
'''

import matplotlib.pyplot as plt


''' Utility function to plot loss
input : training loss
'''
def plot(loss):
	plt.plot([i+1 for i in range(0, len(loss), 2)], loss[::2])
	plt.show()
