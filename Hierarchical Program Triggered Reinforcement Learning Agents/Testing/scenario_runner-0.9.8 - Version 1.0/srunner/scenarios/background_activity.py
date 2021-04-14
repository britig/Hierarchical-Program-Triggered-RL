#!/usr/bin/env python

#
# This work is licensed under the terms of the MIT license.
# For a copy, see <https://opensource.org/licenses/MIT>.

"""
Scenario spawning elements to make the town dynamic and interesting
"""

import py_trees

from srunner.scenariomanager.carla_data_provider import CarlaActorPool
from srunner.scenariomanager.scenarioatomics.atomic_behaviors import TrafficJamChecker
from srunner.scenarios.basic_scenario import BasicScenario
import pickle
import carla


class BackgroundActivity(BasicScenario):

    """
    Implementation of a scenario to spawn a set of background actors,
    and to remove traffic jams in background traffic

    This is a single ego vehicle scenario
    """

    def __init__(self, world, ego_vehicles, config, randomize=False, debug_mode=False, timeout=35 * 60):
        """
        Setup all relevant parameters and create scenario
        """
        self.config = config
        self.debug = debug_mode

        self.timeout = timeout  # Timeout of scenario in seconds

        super(BackgroundActivity, self).__init__("BackgroundActivity",
                                                 ego_vehicles,
                                                 config,
                                                 world,
                                                 debug_mode,
                                                 terminate_on_failure=True,
                                                 criteria_enable=True)

    def _initialize_actors(self, config):
        location = []
        
        infile = open('actor_config5','rb')
        location = pickle.load(infile)
        infile.close()
        for actor in config.other_actors:
            new_actors = []
            new_actors = CarlaActorPool.request_new_batch_actors(actor.model,
                                                                 actor.amount,
                                                                 actor.transform,
                                                                 hero=False,
                                                                 autopilot=actor.autopilot,
                                                                 random_location=actor.random_location)
            #Static obstacle for route based driving 2
            '''transform = carla.Transform(carla.Location(x=-77.3, y=108.4, z=0.0), carla.Rotation(pitch=360.5, yaw=269.8+90, roll=0.0))
            new_actors.append(CarlaActorPool.request_new_actor('static.prop.streetbarrier',
                                                                    transform,
                                                                    hero=False,
                                                                    autopilot=False,
                                                                    random_location=False))'''
            
            
            '''for i in range(len(location)):
                maploc = location[i]
                transform = carla.Transform(carla.Location(x=maploc['x'], y=maploc['y'], z=maploc['z']), carla.Rotation(pitch=maploc['pitch'], yaw=maploc['yaw'], roll=maploc['roll']))
                new_actors.append(CarlaActorPool.request_new_actor(maploc['vehicle'],
                                                                    transform,
                                                                    hero=False,
                                                                    autopilot=True,
                                                                    random_location=False))'''
            if new_actors is None:
                raise Exception("Error: Unable to add actor {} at {}".format(actor.model, actor.transform))

            for _actor in new_actors:
                #print(f'actor_location======={_actor.type_id}')
                loc_dict = {'vehicle':_actor.type_id,'pitch':_actor.get_transform().rotation.pitch,'yaw':_actor.get_transform().rotation.yaw,'roll':_actor.get_transform().rotation.roll,'x':_actor.get_location().x,'y':_actor.get_location().y,'z':_actor.get_location().z}
                location.append(loc_dict)
                self.other_actors.append(_actor)
        '''filename = 'actor_config2'
        outfile = open(filename,'wb')
        pickle.dump(location,outfile)
        outfile.close()'''

    def _create_behavior(self):
        """
        Basic behavior do nothing, i.e. Idle
        """

        # Build behavior tree
        sequence = py_trees.composites.Sequence("BackgroundActivity")
        check_jam = TrafficJamChecker(debug=self.debug)
        sequence.add_child(check_jam)

        return sequence

    def _create_test_criteria(self):
        """
        A list of all test criteria will be created that is later used
        in parallel behavior tree.
        """
        pass

    def __del__(self):
        """
        Remove all actors upon deletion
        """
        self.remove_all_actors()
