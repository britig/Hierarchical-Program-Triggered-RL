#!/usr/bin/env python

#
# This work is licensed under the terms of the MIT license.
# For a copy, see <https://opensource.org/licenses/MIT>.

"""
Control Loss Vehicle scenario:

The scenario realizes that the vehicle looses control due to
bad road conditions, etc. and checks to see if the vehicle
regains control and corrects it's course.
"""

import random
import py_trees
import carla

from srunner.scenariomanager.carla_data_provider import CarlaDataProvider, CarlaActorPool
from srunner.scenariomanager.scenarioatomics.atomic_behaviors import ChangeNoiseParameters, ActorTransformSetter
from srunner.scenariomanager.scenarioatomics.atomic_criteria import CollisionTest
from srunner.scenariomanager.scenarioatomics.atomic_trigger_conditions import (InTriggerDistanceToLocation,
                                                                               InTriggerDistanceToNextIntersection,
                                                                               DriveDistance)
from srunner.scenarios.basic_scenario import BasicScenario
from srunner.tools.scenario_helper import get_location_in_distance_from_wp


class CorlStraight(BasicScenario):

    """
    Implementation of "Control Loss Vehicle" (Traffic Scenario 01)

    This is a single ego vehicle scenario
    """

    def __init__(self, world, ego_vehicles, config, randomize=False, debug_mode=False, criteria_enable=True,
                 timeout=200):
        """
        Setup all relevant parameters and create scenario
        """
        # ego vehicle parameters
        self._start_distance = 20
        self._end_distance = 80
        self._ego_vehicle_max_steer = 0.0
        self._ego_vehicle_max_throttle = 1.0
        self._map = CarlaDataProvider.get_map()
        # Timeout of scenario in seconds
        self.timeout = timeout
        # The reference trigger for the control loss
        self._reference_waypoint = self._map.get_waypoint(config.trigger_points[0].location)
        self.loc_list = []
        self.obj = []
        super(CorlStraight, self).__init__("Corl",
                                          ego_vehicles,
                                          config,
                                          world,
                                          debug_mode,
                                          criteria_enable=criteria_enable)


    



    def _create_behavior(self):
        # endcondition: Check if vehicle reached waypoint _end_distance from here:
        end_condition = DriveDistance(self.ego_vehicles[0], self._end_distance)
        # Build behavior tree
        sequence = py_trees.composites.Sequence("Corl")
        sequence.add_child(end_condition)
        return sequence



    def _create_test_criteria(self):
        """
        A list of all test criteria will be created that is later used
        in parallel behavior tree.
        """
        criteria = []

        collision_criterion = CollisionTest(self.ego_vehicles[0])
        criteria.append(collision_criterion)

        return criteria

    def __del__(self):
        """
        Remove all actors upon deletion
        """
        self.remove_all_actors()


class OneTurn(BasicScenario):

    """
    Implementation of "Control Loss Vehicle" (Traffic Scenario 01)

    This is a single ego vehicle scenario
    """

    def __init__(self, world, ego_vehicles, config, randomize=False, debug_mode=False, criteria_enable=True,
                 timeout=200):
        """
        Setup all relevant parameters and create scenario
        """
        # ego vehicle parameters
        self._start_distance = 20
        self._end_distance = 60
        self._ego_vehicle_max_steer = 0.0
        self._ego_vehicle_max_throttle = 1.0
        self._map = CarlaDataProvider.get_map()
        # Timeout of scenario in seconds
        self.timeout = timeout
        # The reference trigger for the control loss
        self._reference_waypoint = self._map.get_waypoint(config.trigger_points[0].location)
        self.loc_list = []
        self.obj = []
        super(OneTurn, self).__init__("Corl",
                                          ego_vehicles,
                                          config,
                                          world,
                                          debug_mode,
                                          criteria_enable=criteria_enable)


    



    def _create_behavior(self):
        # endcondition: Check if vehicle reached waypoint _end_distance from here:
        end_condition = DriveDistance(self.ego_vehicles[0], self._end_distance)
        # Build behavior tree
        sequence = py_trees.composites.Sequence("Corl")
        sequence.add_child(end_condition)
        return sequence



    def _create_test_criteria(self):
        """
        A list of all test criteria will be created that is later used
        in parallel behavior tree.
        """
        criteria = []

        collision_criterion = CollisionTest(self.ego_vehicles[0])
        criteria.append(collision_criterion)

        return criteria

    def __del__(self):
        """
        Remove all actors upon deletion
        """
        self.remove_all_actors()


class Navigation(BasicScenario):

    """
    Implementation of "Control Loss Vehicle" (Traffic Scenario 01)

    This is a single ego vehicle scenario
    """

    def __init__(self, world, ego_vehicles, config, randomize=False, debug_mode=False, criteria_enable=True,
                 timeout=200):
        """
        Setup all relevant parameters and create scenario
        """
        # ego vehicle parameters
        self._start_distance = 0
        self._end_distance = 150
        self._ego_vehicle_max_steer = 0.0
        self._ego_vehicle_max_throttle = 1.0
        self._map = CarlaDataProvider.get_map()
        # Timeout of scenario in seconds
        self.timeout = timeout
        # The reference trigger for the control loss
        self._reference_waypoint = self._map.get_waypoint(config.trigger_points[0].location)
        self.loc_list = []
        self.obj = []
        super(Navigation, self).__init__("Corl",
                                          ego_vehicles,
                                          config,
                                          world,
                                          debug_mode,
                                          criteria_enable=criteria_enable)


    



    def _create_behavior(self):
        # endcondition: Check if vehicle reached waypoint _end_distance from here:
        end_condition = DriveDistance(self.ego_vehicles[0], self._end_distance)
        # Build behavior tree
        sequence = py_trees.composites.Sequence("Corl")
        sequence.add_child(end_condition)
        return sequence



    def _create_test_criteria(self):
        """
        A list of all test criteria will be created that is later used
        in parallel behavior tree.
        """
        criteria = []

        collision_criterion = CollisionTest(self.ego_vehicles[0])
        criteria.append(collision_criterion)

        return criteria

    def __del__(self):
        """
        Remove all actors upon deletion
        """
        self.remove_all_actors()