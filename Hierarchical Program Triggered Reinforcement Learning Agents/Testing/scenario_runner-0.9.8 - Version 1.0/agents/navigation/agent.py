#!/usr/bin/env python

# Copyright (c) 2018 Intel Labs.
# authors: German Ros (german.ros@intel.com)
#
# This work is licensed under the terms of the MIT license.
# For a copy, see <https://opensource.org/licenses/MIT>.

""" This module implements an agent that roams around a track following random
waypoints and avoiding other vehicles.
The agent also responds to traffic lights. """

from enum import Enum

import carla
from agents.tools.misc import is_within_distance_ahead, compute_magnitude_angle, target_magnitude,distance_vehicle


class AgentState(Enum):
    """
    AGENT_STATE represents the possible states of a roaming agent
    """
    NAVIGATING = 1
    BLOCKED_BY_VEHICLE = 2
    BLOCKED_RED_LIGHT = 3
    BLOCKED_IN_JUNCTION = 4


class Agent(object):
    """
    Base class to define agents in CARLA
    """

    def __init__(self, vehicle):
        """

        :param vehicle: actor to apply to local planner logic onto
        """
        self._vehicle = vehicle
        self._proximity_threshold = 10.0  # meters
        self._local_planner = None
        self._world = self._vehicle.get_world()
        self._map = self._vehicle.get_world().get_map()
        self._last_traffic_light = None

    def run_step(self, debug=False):
        """
        Execute one step of navigation.
        :return: control
        """
        control = carla.VehicleControl()

        if debug:
            control.steer = 0.0
            control.throttle = 0.0
            control.brake = 0.0
            control.hand_brake = False
            control.manual_gear_shift = False

        return control

    def _is_light_red(self, lights_list):
        """
        Method to check if there is a red light affecting us. This version of
        the method is compatible with both European and US style traffic lights.

        :param lights_list: list containing TrafficLight objects
        :return: a tuple given by (bool_flag, traffic_light), where
                 - bool_flag is True if there is a traffic light in RED
                   affecting us and False otherwise
                 - traffic_light is the object itself or None if there is no
                   red traffic light affecting us
        """
        if self._map.name == 'Town01' or self._map.name == 'Town02':
            return self._is_light_red_europe_style(lights_list)
        else:
            return self._is_light_red_us_style(lights_list)

    def _is_light_red_europe_style(self, lights_list):
        """
        This method is specialized to check European style traffic lights.

        :param lights_list: list containing TrafficLight objects
        :return: a tuple given by (bool_flag, traffic_light), where
                 - bool_flag is True if there is a traffic light in RED
                  affecting us and False otherwise
                 - traffic_light is the object itself or None if there is no
                   red traffic light affecting us
        """
        ego_vehicle_location = self._vehicle.get_location()
        ego_vehicle_waypoint = self._map.get_waypoint(ego_vehicle_location)

        for traffic_light in lights_list:
            object_waypoint = self._map.get_waypoint(traffic_light.get_location())
            if object_waypoint.road_id != ego_vehicle_waypoint.road_id or \
                    object_waypoint.lane_id != ego_vehicle_waypoint.lane_id:
                continue

            if is_within_distance_ahead(traffic_light.get_transform(),
                                        self._vehicle.get_transform(),
                                        self._proximity_threshold):
                if traffic_light.state == carla.TrafficLightState.Red:
                    return (True, traffic_light)

        return (False, None)

    def _is_light_red_us_style(self, lights_list, debug=False):
        """
        This method is specialized to check US style traffic lights.

        :param lights_list: list containing TrafficLight objects
        :return: a tuple given by (bool_flag, traffic_light), where
                 - bool_flag is True if there is a traffic light in RED
                   affecting us and False otherwise
                 - traffic_light is the object itself or None if there is no
                   red traffic light affecting us
        """
        ego_vehicle_location = self._vehicle.get_location()
        ego_vehicle_waypoint = self._map.get_waypoint(ego_vehicle_location)

        if ego_vehicle_waypoint.is_junction:
            # It is too late. Do not block the intersection! Keep going!
            return (False, None)

        if self._local_planner.target_waypoint is not None:
            if self._local_planner.target_waypoint.is_junction:
                min_angle = 180.0
                sel_magnitude = 0.0
                sel_traffic_light = None
                for traffic_light in lights_list:
                    loc = traffic_light.get_location()
                    magnitude, angle = compute_magnitude_angle(loc,
                                                               ego_vehicle_location,
                                                               self._vehicle.get_transform().rotation.yaw)
                    if magnitude < 60.0 and angle < min(25.0, min_angle):
                        sel_magnitude = magnitude
                        sel_traffic_light = traffic_light
                        min_angle = angle

                if sel_traffic_light is not None:
                    if debug:
                        print('=== Magnitude = {} | Angle = {} | ID = {}'.format(
                            sel_magnitude, min_angle, sel_traffic_light.id))

                    if self._last_traffic_light is None:
                        self._last_traffic_light = sel_traffic_light

                    if self._last_traffic_light.state == carla.TrafficLightState.Red:
                        return (True, self._last_traffic_light)
                else:
                    self._last_traffic_light = None

        return (False, None)

    def _is_vehicle_hazard(self, vehicle_list):
        """
        Check if a given vehicle is an obstacle in our way. To this end we take
        into account the road and lane the target vehicle is on and run a
        geometry test to check if the target vehicle is under a certain distance
        in front of our ego vehicle.

        WARNING: This method is an approximation that could fail for very large
         vehicles, which center is actually on a different lane but their
         extension falls within the ego vehicle lane.

        :param vehicle_list: list of potential obstacle to check
        :return: a tuple given by (bool_flag, vehicle), where
                 - bool_flag is True if there is a vehicle ahead blocking us
                   and False otherwise
                 - vehicle is the blocker object itself
        """

        ego_vehicle_location = self._vehicle.get_location()
        ego_vehicle_waypoint = self._map.get_waypoint(ego_vehicle_location)

        for target_vehicle in vehicle_list:
            # do not account for the ego vehicle
            if target_vehicle.id == self._vehicle.id:
                continue

            # if the object is not in our lane it's not an obstacle
            target_vehicle_waypoint = self._map.get_waypoint(target_vehicle.get_location())
            if target_vehicle_waypoint.road_id != ego_vehicle_waypoint.road_id or \
                    target_vehicle_waypoint.lane_id != ego_vehicle_waypoint.lane_id:
                continue

            if is_within_distance_ahead(target_vehicle.get_transform(),
                                        self._vehicle.get_transform(),
                                        self._proximity_threshold):
                return (True, target_vehicle)

        return (False, None)

    # Python program to find the intersection 
    # of two lists using set() method 
    def intersection(self, lst1, lst2):
        temp = set(lst2) 
        lst3 = [value for value in lst1 if value in temp] 
        return lst3

    def _is_junction_hazard(self, vehicle_list):
        """
        Check if both the ego vehicle and other vehicle are at the junction point
        :param vehicle_list: list of potential obstacle to check
        :Check if both the vehicles are in the same junction
        :Check interesection between the two routes
        :Block ego vehicle only if the target vehicle has route priority
        :return: a tuple given by (bool_flag, vehicle), where
                 - bool_flag is True if there is a vehicle ahead blocking us
                   and False otherwise
                 - vehicle is the blocker object itself
        Author : Briti Gangopadhyay
        """

        ego_vehicle_location = self._vehicle.get_location()
        ego_vehicle_waypoint = self._map.get_waypoint(ego_vehicle_location)
        ego_vehicle_waypoint_list = []
        target_vehicle_waypoint_list = []
        ego_vehicle_loc_list = []
        target_vehicle_loc_list = []


        for target_vehicle in vehicle_list:
            # do not account for the ego vehicle
            if target_vehicle.id == self._vehicle.id:
                continue
            
            target_vehicle_waypoint = self._map.get_waypoint(target_vehicle.get_location())
            #Check if both the ego vehicle and the target vehicle are on the junction
            #And the juction has same id for both the vehicles
            if (ego_vehicle_waypoint.is_junction and target_vehicle_waypoint.is_junction and (ego_vehicle_waypoint.get_junction().id == target_vehicle_waypoint.get_junction().id)):
                #Calculate the route intersection of the two vehicle to calculate route priority
                ini_ego_loc_x = round(ego_vehicle_waypoint.next(0.1)[0].transform.location.x)
                ini_ego_loc_y = round(ego_vehicle_waypoint.next(0.1)[0].transform.location.y)
                ini_target_loc_x = round(target_vehicle_waypoint.next(0.1)[0].transform.location.x)
                ini_target_loc_y = round(target_vehicle_waypoint.next(0.1)[0].transform.location.y)
                ego_vehicle_loc_list.append((ini_ego_loc_x,ini_ego_loc_y))
                target_vehicle_loc_list.append((ini_target_loc_x,ini_target_loc_y))
                ego_vehicle_waypoint_list.append(ego_vehicle_waypoint.next(1)[0])
                target_vehicle_waypoint_list.append(target_vehicle_waypoint.next(1)[0])
                #Take a set next 15 predicted waypoints to calculate intersection
                for i in range(15):
                    ego_loc_x = round(ego_vehicle_waypoint_list[i].next(0.1)[0].transform.location.x)
                    ego_loc_y = round(ego_vehicle_waypoint_list[i].next(0.1)[0].transform.location.y)
                    target_loc_x = round(target_vehicle_waypoint_list[i].next(0.1)[0].transform.location.x)
                    target_loc_y = round(target_vehicle_waypoint_list[i].next(0.1)[0].transform.location.y)
                    ego_vehicle_loc_list.append((ego_loc_x,ego_loc_y))
                    target_vehicle_loc_list.append((target_loc_x,target_loc_y))
                    ego_vehicle_waypoint_list.append(ego_vehicle_waypoint_list[i].next(1)[0])
                    target_vehicle_waypoint_list.append(target_vehicle_waypoint_list[i].next(1)[0])
                print('========= BOTH VEHICLES IN JUNCTION')
                #print(f'=============Ego vehicle location list {ego_vehicle_loc_list}')
                #print(f'=============target vehicle location list {target_vehicle_loc_list}')
                intersection_list = self.intersection(ego_vehicle_loc_list,target_vehicle_loc_list)
                #print(f'============= intersection between two lists {intersection_list}')
                #If the routes intersect the intersection list is non empty
                if len(intersection_list)!=0 and ego_vehicle_waypoint.get_junction().id!=172:
                    #Calculate the normal distance from the first location to the intersection location
                    target_diff = target_magnitude(target_vehicle_loc_list[0],intersection_list[0])
                    ego_diff = target_magnitude(ego_vehicle_loc_list[0],intersection_list[0])
                    print(f'============= Diff ===== target==== {target_diff} == egodiff == {ego_diff}')
                    #Block the ego vehicle only if the other vehicle has higher route priority
                    if(target_diff<ego_diff):
                        return (True, target_vehicle)

        return (False, None)

    def _is_static_obstacle_ahead(self,prop_list):
        """
        Check if a static obstacle is in the ego vehicles way.
        """
        ego_vehicle_location = self._vehicle.get_location()
        ego_vehicle_waypoint = self._map.get_waypoint(ego_vehicle_location)
        for static_obstacle in prop_list:
            static_obstacle_waypoint = self._map.get_waypoint(static_obstacle.get_location())
            if static_obstacle_waypoint.road_id != ego_vehicle_waypoint.road_id or \
                    static_obstacle_waypoint.lane_id != ego_vehicle_waypoint.lane_id:
                continue
            if is_within_distance_ahead(static_obstacle.get_transform(),
                                        self._vehicle.get_transform(),
                                        18):
                return (True, static_obstacle)
        return (False, None)


    #Check if the target lane is clear for lane shift
    def _is_next_lane_clear(self,next_lane_waypoint,vehicle_list):
        approx_distance_waypoint = next_lane_waypoint.previous(20)[0]
        print(f'approx_distance_waypoint======={approx_distance_waypoint}')
        for target_vehicle in vehicle_list:
            target_vehicle_waypoint = self._map.get_waypoint(target_vehicle.get_location())
            # do not account for the vehicles on the non target lane
            if target_vehicle_waypoint.lane_id != next_lane_waypoint.lane_id:
                continue
            print(f'target_vehicle_waypoint======={target_vehicle_waypoint}')
            if is_within_distance_ahead(approx_distance_waypoint.transform,
                                        target_vehicle.get_transform(),
                                        45):
                return False

        return True


    def emergency_stop(self):
        """
        Send an emergency stop command to the vehicle
        :return:
        """
        control = carla.VehicleControl()
        control.steer = 0.0
        control.throttle = 0.0
        control.brake = 1.0
        control.hand_brake = False

        return control
