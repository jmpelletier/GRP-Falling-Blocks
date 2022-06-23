# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

func _on_gaze_update(left_coords, right_coords, _timestamp, epoch):
	var gaze = {
		"left": {"x": left_coords.x, "y": left_coords.y}, 
		"right": {"x": right_coords.x, "y": right_coords.y}
	}
	
	var json_str = JSON.print(gaze)
	
	Logger.log_external_event(epoch, "gaze", json_str)
