# Hierarchical-Program-Triggered-RL
This folder contains the experiments and code for Hierarchical Program Triggered RL paper (https://ieeexplore.ieee.org/document/9497870). Entire framework is built on CARLA version 0.9.8 : https://carla.org/2020/03/09/releas and Python 3.6 and above. The sub dependencies are mentioned inside each folder.

## Folder Structure

### Training

Contains code for training the Deep Q Learning and the Deep Deterministic policy gradient agents.

### Testing

The Testing of HPRL agents have been conducted on NHTSA pre crash scenarios modelled in Scenario Runner 0.9.8

Scenario Runner documentation : https://carla-scenariorunner.readthedocs.io/en/latest/
List of Supported Scenario : https://carla-scenariorunner.readthedocs.io/en/latest/list_of_scenarios/


Control Loss               |  No Signal Junction
:-------------------------:|:-------------------------:
![](https://github.com/britig/Hierarchical-Program-Triggered-RL/blob/main/Hierarchical%20Program%20Triggered%20Reinforcement%20Learning%20Agents/GIF/ControlLoss1.gif)  |  ![](https://github.com/britig/Hierarchical-Program-Triggered-RL/blob/main/Hierarchical%20Program%20Triggered%20Reinforcement%20Learning%20Agents/GIF/NoSignalJunction.gif)
**Vehicle Passing**        |  **Obstacle Avoidance**
![](https://github.com/britig/Hierarchical-Program-Triggered-RL/blob/main/Hierarchical%20Program%20Triggered%20Reinforcement%20Learning%20Agents/GIF/Scenario6.gif)  |  ![](https://github.com/britig/Hierarchical-Program-Triggered-RL/blob/main/Hierarchical%20Program%20Triggered%20Reinforcement%20Learning%20Agents/GIF/VehicleTurningLeft.gif)

### Verification

Verification has been conducted by using Nagini : https://github.com/marcoeilers/nagini.

### Videos

Contains the experiment simulation videos.
