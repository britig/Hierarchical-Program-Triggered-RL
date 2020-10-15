#!/usr/bin/env python

# Copyright (c) 2020 IIT Kharagpur

"""
This module provides a route parser for the given scenario
returns a list of <road.option, start x,y coordinate, end x,y coordinate>
example <[straight, (x=0,y=0),(x=10,y=10)]>
"""

import os
import glob
import xml.etree.ElementTree as ET

class ScenarioRouteParser(object):

	"""
	Parser a route file that matches the scenario name
	"""

	def __init__(self, scenario_name):
		self.scenario_name = scenario_name
		self.config_file = self._get_config_file(scenario_name)

	def _get_config_file(self,scenario_name):
		"""
		Parse *all* config files and find first match for scenario config
		"""
		list_of_config_files = glob.glob("{}/srunner/scenarioroute/*.xml".format(os.getenv('ROOT_SCENARIO_RUNNER', "./")))
		for file_name in list_of_config_files:
			tree = ET.parse(file_name)
			for scenario in tree.iter("scenario"):
				if scenario.attrib.get('name', None) == self.scenario_name:
					return file_name
		return None


	def _extract_route_from_tree(self):
		"""
		Returns a route list after parsing the config file
		"""
		route_list = []
		if self.config_file == None:
			return route_list
		tree = ET.parse(self.config_file)
		for scenario in tree.iter("scenario"):
			if scenario.attrib.get('name', None) == self.scenario_name:
				for child in scenario:
					route = []
					route.append(child.tag)
					route.append((child.attrib.get('startx', None),child.attrib.get('starty', None)))
					route.append((child.attrib.get('endx', None),child.attrib.get('endy', None)))
					route_list.append(route)
		return route_list