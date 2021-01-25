[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/carla-simulator/scenario_runner.svg)
[![Build Status](https://travis-ci.com/carla-simulator/scenario_runner.svg?branch=master)](https://travis-ci.com/carla/scenario_runner)

Modifications:

IIT Kharagpur
Formal Methods Lab
Author : Briti Gangopadhyay ©
Project : Hierarchical Program Controlled Reinforcement Learning

ScenarioRunner for HPRL agents in CARLA
=======================================
This repository contains traffic scenario definition and an execution engine
for CARLA. You 
Scenarios can be defined through a Python interface, and with the newest version
the scenario_runner also the upcoming [OpenSCENARIO](http://www.openscenario.org/) standard is supported.

[![Scenario_Runner for CARLA](Docs/img/scenario_runner_video.png)](https://youtu.be/ChmF8IFagpo?t=68)

This also contains the supervisory controller Program P emebedded with the following assertions:
 -- Stop at Red Light
 -- Maintain Longitudinal and Lateral safe distance
 -- Junction priority (This is implemented in _is_junction_hazard in agent.py)
 -- Lane clearace before lane change


Getting the ScenarioRunner for HPRL
-----------------------------------

Use `git clone` or download the project from this page. Note that the master
branch contains the latest fixes and features, and may be required to use the latest features from CARLA.

It is important to also consider the release version that has to match the CARLA version. Currently the HPRL framework only supports CARLA version 0.9.8.
Supports both Windows/Linux.

* [Version 0.9.8](https://github.com/carla-simulator/scenario_runner/releases/tag/v0.9.8) 


Currently no build is required, as all code is in Python.

System Configuration
--------------------

The code has been developed and tested on a laptop with 4-core 2.4GHz Intel Core i5 9th Gen and NVIDIA GeForce GTX TITAN
in Windows Operating System. This also works in linux/ubuntu with few modifications (The user may debug this during installation).

**Rquired** - Place this folder inside CARLA_0.9.8\WindowsNoEditor\PythonAPI\examples\ or import the carla egg file from proper location
**Rquired** - Change sys path to carla path in your folder in the file challenges/env/scene_layout_sensor.py , install dependencies (py_trees,xmlschema,shapely etc mentioned in requirements.txt)
**Rquired** - Place the carla egg package unzipped insid python/lib/site-packages (For linux sudo easy_install path_to_egg)

Using the ScenarioRunner for HPRL
---------------------------------

List of Supported scenarios
1) ControlLoss_1
2) ControlLoss_8,ControlLoss_9
3) FollowLeadingVehicleWithObstacle_4
4) VehicleTurningRight_7
5) VehicleTurningLeft_7
6) SignalizedJunctionRightTurn_1
7) NoSignalJunctionCrossing
8) SignalizedJunctionLeftTurn_1
9) OppositeVehicleRunningRedLight031
10) ManeuverOppositeDirection_1

**Rquired** - For any other scenario the route needs to be defined

To run a particular scenario follow the below steps:
1) Start CARLA server
2) Open command promt/Terminal and cd to base folder of scenario_runner-0.9.8 - V1.0 and execute python scenario_runner.py --scenario <Scenario Name>
Example : python scenario_runner.py --scenario ControlLoss_1
3) Open a second command promt/Terminal and cd to base folder of scenario_runner-0.9.8 - V1.0 and execute python nn_control.py --scenario <Scenario Name>
Example : python nn_control.py --scenario ControlLoss_1
This will begin the simulation once the scenario is ready
You can also run python manual_control.py to manually controll the ego vehicle in a scenario
 
To run a challenge route scenario follow the below steps:

1) Start CARLA server
2) Open command promt/Terminal and cd to base folder of scenario_runner-0.9.8 - V1.0 and execute python scenario_runner.py --route srunner/challenge/routes_custom.xml srunner/challenge/all_towns_traffic_scenarios.json 0
3) Open a second command promt/Terminal and cd to base folder of scenario_runner-0.9.8 - V1.0 and execute python nn_control.py --scenario Challenge


Things to keep in mind:
1) When loading a new world run python scenario_runner.py --scenario ControlLoss1 --reloadWorld and then run python scenario_runner.py --scenario ControlLoss1 again on recieving an error
2) When trying a new scenario the route must be defined in scenario_runner-0.9.8 - V1.0\srunner\scenarioroute
3) If the pygame window does not automatically close on terminaton of a scenario press escape

**Disclaimer** - The neural network models are still under development and may sometimes behave arbitarily

FAQ
------

If you run into problems with scenario runner, check
[FAQ](http://carla.readthedocs.io/en/latest/faq/).

License
-------

ScenarioRunner specific code is distributed under MIT License.
