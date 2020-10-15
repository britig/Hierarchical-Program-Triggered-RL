# Come Nagini let us verify this python code :D
# Author : Briti Gangopadhyay
# Project : HPRL
# Module responsible for validating an abstract version of of the NN_Agent class controlling the ego vehicle
# Uses Z3 - 64 bit as SMT backend and viper backend silicon
# Nagini used from https://pypi.org/project/nagini/

from nagini_contracts.contracts import *
from nagini_contracts.io_contracts import *
from typing import Tuple, Callable, List,Any,cast

class NNAgent(Agent):

    #Input and return type
    def __init__(self,vehicle: Vehicle, target_speed: float,vehicle_list: List[Vehicle]) -> None:
        Ensures(Acc(self.vehicle) and self.vehicle == vehicle)
        
        super(NNAgent, self).__init__(vehicle)

        self.vehicle = vehicle     # type: Vehicle
        self.ego_vehicle = vehicle  # type: Vehicle
        self._blocking_threshold = 20 #type : int
        self._state = 'NAVIGATING' #type : str
        self.vehicle_list = vehicle_list #type : List[Vehicle]
        self.vehicle_list1 = vehicle_list #type : List[Vehicle]
        self.time_count = 0
        self.vehicle_junction_hazard = False #type : bool

    def run_step(self) -> int:
        Requires(Acc(self._state))
        Requires(Acc(self.vehicle_junction_hazard) and Acc(self.time_count) and Acc(self._blocking_threshold))
        Requires(Acc(self.vehicle_list))
        Requires(Acc(self.vehicle_list1))
        Requires(Acc(self.vehicle))# type: ignore
        Requires(Acc(self.ego_vehicle))# type: ignore
        Requires(Acc(self.vehicle.loc_x))# type: ignore
        Requires(Acc(self.ego_vehicle.loc_x))# type: ignore
        Requires(Acc(self.vehicle.loc_y))# type: ignore
        Requires(Acc(self.ego_vehicle.loc_y))# type: ignore
        Requires(Acc(self.vehicle.id))# type: ignore
        Requires(Acc(self.ego_vehicle.id))# type: ignore
        Requires(Acc(self.vehicle.brake))# type: int
        Requires(Acc(self.vehicle.steer))# type: int
        Requires(Acc(self.vehicle.throttle))# type: int
        Requires(Acc(self.vehicle.is_junction))# type: ignore
        Requires(Acc(self.ego_vehicle.is_junction))# type: ignore
        Requires(Acc(list_pred(self.vehicle_list)))
        Requires(Acc(list_pred(self.vehicle_list1)))
        Requires(Forall(self.vehicle_list, lambda i: Acc(i.id) and Acc(i.loc_x) and Acc(i.loc_y)))#type: ignore
        Requires(Forall(self.vehicle_list1, lambda i: Acc(i.id) and Acc(i.loc_x) and Acc(i.loc_y) and Acc(i.is_junction)))#type: ignore
        Ensures(Acc(self.vehicle_list))
        Ensures(Acc(self.vehicle))# type: ignore
        Ensures(Acc(self.vehicle_junction_hazard))# type: ignore
        hazard_detected = False #type : bool
        lane_change = False #type: bool
        control = 5 #type : float
        light_list = ['r','y','g'] #type : List[str]

        #Dummy list to non deterministically return true of false
        #Validating that light state red leads to the car stopping
        light_state = self._is_light_red(light_list)
        if light_state:
            self._state = 'BLOCKED_RED_LIGHT'
            hazard_detected = True
        Assert(Implies(light_state, hazard_detected))

        #Validating that vehicle violating the proximity distance leads to car being stopped
        vehicle_state = _is_vehicle_hazard(self.vehicle_list,self.vehicle)# type: ignore
        if vehicle_state and not lane_change:
            self.time_count = self.time_count + 1
            if self.time_count>self._blocking_threshold:
                lane_change = True
                next_lane_waypoint = (cast(int,self.ego_vehicle.loc_x)+1,cast(int,self.ego_vehicle.loc_y)+1)# type: ignore
                Assert(Implies((self.time_count>self._blocking_threshold and not lane_change), lane_change))
            self._state = 'BLOCKED_BY_VEHICLE'
            hazard_detected = True
        Assert(Implies((vehicle_state and not lane_change), hazard_detected))
        
        #Check the if there is a junction class between ego and another vehicle
        #If there is a junction class check for priority
        if not self.vehicle_junction_hazard:
            #Return True only if another vehicle has higher priority
            self.vehicle_junction_hazard = _is_junction_hazard(self.vehicle_list1,self.ego_vehicle)# type: ignore
        if self.vehicle_junction_hazard and self.vehicle.is_junction:# type: ignore
            self._state = 'BLOCKED_IN_JUNCTION'
            self.vehicle.brake = 1
            self.vehicle.steer = 0 #type :int
            self.vehicle.throttle = 0
            return control
        else:
            self.vehicle_junction_hazard = False#type :bool

        Assert(Implies((self.vehicle_junction_hazard),
        self.vehicle.brake == 1 and self.vehicle.steer == 0 and 
        self.vehicle.throttle == 0))


        if hazard_detected and not lane_change:
            self.vehicle.brake = 1
            self.vehicle.steer = 0 #type :int
            self.vehicle.throttle = 0
            control = self.emergency_stop()
            return control
        elif lane_change:
            control = self.execute_lane_change()
            lane_change=False
            self.time_count = 0
            return control
        else:
            control = self.execute_nn_control()
        
        Assert(Implies((not(hazard_detected) and not(lane_change)), 
        control == self.execute_nn_control()))

        Assert(Implies((hazard_detected and not lane_change), 
        self.vehicle.brake == 1 and self.vehicle.steer == 0 and 
        self.vehicle.throttle == 0))

        return control

    def check_functional_safety(self)->int:
        return 0


#Implements dummy methods to formally verify the assertions implemented in the program
class Agent():
    def __init__(self,vehicle : Vehicle)-> None:
        #Requires(Acc(self.vehicle))
        #Ensures(Acc(self.vehicle))  # type: ignore
        Ensures(Acc(self.light_state))  # type: ignore
        #self.vehicle = vehicle     # type: Vehicle
        self.light_state = False  # type : bool

    #Dummy method for is light red this will be determined by carla methods
    def _is_light_red(self, light_List  : List[str])-> bool:
        Requires(Acc(list_pred(light_List)))
        if 'c' in light_List:
            return True
        return False

    #Dummy methods to mimic the main program
    def execute_lane_change(self)->int:
        return 100

    @Pure
    def execute_nn_control(self)->int:
        return 50

    def emergency_stop(self)->int:
        return 0

#Method to check if ego vehicle maintains longitudinal safe distance with another vehicle
def _is_vehicle_hazard(vehicle_List  : List[Vehicle],ego_vehicle :  Vehicle)-> bool:
    Requires(Acc(list_pred(vehicle_List)))
    Requires(Acc(ego_vehicle.loc_x))#type: ignore
    Requires(Acc(ego_vehicle.loc_y))#type: ignore
    Requires(Acc(ego_vehicle.id))#type: ignore
    Requires(Forall(vehicle_List, lambda i: Acc(i.id) and Acc(i.loc_x) and Acc(i.loc_y)))#type: ignore
    proximity_threshold = 15
    norm_distance = 50
    ego_loc_x = cast(int,ego_vehicle.loc_x)#type: ignore
    ego_loc_y = cast(int,ego_vehicle.loc_y)#type: ignore
    for target_vehicle in vehicle_List:
        Invariant(Acc(ego_vehicle.id))#type: ignore
        Invariant(norm_distance> proximity_threshold)
        Invariant(Forall(vehicle_List, lambda i: Acc(i.id) and Acc(i.loc_x) and Acc(i.loc_y)))#type: ignore
        if ego_vehicle.id == target_vehicle.id:#type: ignore
            continue
        vehicle_loc_x = cast(int,target_vehicle.loc_x)#type: ignore
        vehicle_loc_y = cast(int,target_vehicle.loc_y)#type: ignore
        norm_distance = ((ego_loc_x-vehicle_loc_x)*(ego_loc_x-vehicle_loc_x) +(ego_loc_y-vehicle_loc_y)*(ego_loc_y-vehicle_loc_y))#type: ignore
        if norm_distance <= proximity_threshold:
            return True
            Assert(Implies(norm_distance <= proximity_threshold,Result()==True))

    return False

#Method to check route priority in case of junction hazard
def _is_junction_hazard(vehicle_List  : List[Vehicle],ego_vehicle :  Vehicle)-> bool:
    Requires(Acc(list_pred(vehicle_List)))
    Requires(Acc(ego_vehicle.loc_x) and Acc(ego_vehicle.loc_y) and Acc(ego_vehicle.id) and Acc(ego_vehicle.is_junction))#type: ignore
    Requires(Forall(vehicle_List, lambda i: Acc(i.id) and Acc(i.loc_x) and Acc(i.loc_y) and Acc(i.is_junction)))#type: ignore
    ego_vehicle_waypoint_list = [] #type: List[Tuple[int, int]]
    target_vehicle_waypoint_list = []#type: List[Tuple[int, int]]
    for target_vehicle in vehicle_List:
        Invariant(Acc(ego_vehicle.id) and Acc(ego_vehicle.loc_x) and Acc(ego_vehicle.loc_y) and Acc(ego_vehicle.is_junction))#type: ignore
        Invariant(Forall(vehicle_List, lambda i: Acc(i.id) and Acc(i.loc_x) and Acc(i.loc_y) and Acc(i.is_junction)))#type: ignore
        Invariant(Acc(list_pred(ego_vehicle_waypoint_list)) and Acc(list_pred(target_vehicle_waypoint_list)))
        if ego_vehicle.id == target_vehicle.id:#type: ignore
            continue
        #Check if both the ego vehicle and the target vehicle are on the junction
        if ego_vehicle.is_junction and target_vehicle.is_junction:#type: ignore
            ini_ego_loc_x = cast(int,ego_vehicle.loc_x)#type: ignore
            ini_ego_loc_y  = cast(int,ego_vehicle.loc_y)#type: ignore
            ini_target_loc_x = cast(int,target_vehicle.loc_x)#type: ignore
            ini_target_loc_y = cast(int,target_vehicle.loc_y)#type: ignore
            ego_vehicle_waypoint_list.append((ini_ego_loc_x,ini_ego_loc_x))
            target_vehicle_waypoint_list.append((ini_target_loc_x,ini_target_loc_y))
            ego_loc_x = ini_ego_loc_x#type: ignore
            ego_loc_y = ini_ego_loc_y#type: ignore
            target_loc_x = ini_target_loc_x#type: ignore
            target_loc_y = ini_target_loc_y#type: ignore
            #Take a set next 15 predicted waypoints to calculate intersection
            for i in range(0,15):
                Invariant(Acc(list_pred(ego_vehicle_waypoint_list)) and Acc(list_pred(target_vehicle_waypoint_list)))
                ego_loc_x = ego_loc_x+1
                ego_loc_y = ego_loc_y+1
                target_loc_x = target_loc_x+1
                target_loc_y = target_loc_y+1
                ego_vehicle_waypoint_list.append((ego_loc_x,ego_loc_y))
                target_vehicle_waypoint_list.append((target_loc_x,target_loc_y))
            temp = set(target_vehicle_waypoint_list)
            intersection_list = [value for value in ego_vehicle_waypoint_list]
            #If the routes intersect the intersection list is non empty
            if len(intersection_list)!=0:
                interesction_x = intersection_list[0][0]
                interesction_y = intersection_list[0][1]
                target_diff = ((interesction_x-ini_target_loc_x)*(interesction_x-ini_target_loc_x)+(interesction_y-ini_target_loc_y)*(interesction_y-ini_target_loc_y))
                ego_diff =  ((interesction_x-ini_ego_loc_x)*(interesction_x-ini_ego_loc_x)+(interesction_y-ini_ego_loc_y)*(interesction_y-ini_ego_loc_y))
                if(target_diff<ego_diff):
                    return True
            Assert(Implies(len(intersection_list)!=0 and target_diff<ego_diff,True))

    return False

class Vehicle():
    def __init__(self, veh_id : int, x : int, y : int, z : int)-> None:
        Ensures(Acc(self.loc_x))  # type: ignore
        Ensures(Acc(self.loc_y))  # type: ignore
        Ensures(Acc(self.loc_z))  # type: ignore
        Ensures(Acc(self.brake))  # type: ignore
        Ensures(Acc(self.steer))  # type: ignore
        Ensures(Acc(self.throttle)) # type: ignore
        Ensures(Acc(self.hand_brake))  # type: ignore
        Ensures(Acc(self.id))  # type: ignore
        Ensures(Acc(self.is_junction))  # type: ignore
        self.id = veh_id 
        self.loc_x = x #type : int
        self.loc_y = y #type : int
        self.loc_z = z #type : int
        self.pitch = 0 #type : float
        self.roll = 0 #type : float
        self.yaw = 0 #type : float
        self.steer = 0 #type: int
        self.throttle = 0 #type: int
        self.brake = 0 #type: int
        self.hand_brake = False #type : bool
        self.is_junction = False #type : bool



def main() -> None:
    vehicle_1 = Vehicle(2,20,10,1)
    vehicle_2 = Vehicle(3,50,2,1)
    ego = Vehicle(1,10,10,1)
    vehicle_list = [ego,vehicle_1,vehicle_2]
    agent = NNAgent(ego,30.0,vehicle_list)

    while True:
        control  = agent.check_functional_safety()