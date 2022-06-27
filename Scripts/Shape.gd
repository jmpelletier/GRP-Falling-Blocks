# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends Node2D

# Returns the collision bounds in local coordinates as an array
# that contains the following values:
# (x_min, y_min, x_max, y_max)
func get_bounds():
	var bounds = [0, 0, 0, 0]
	var init = false
	for child in get_children():
		if child is Block:
			var block_bounds = child.get_bounds()
			if init:
				bounds[0] = min(bounds[0], block_bounds[0])
				bounds[1] = min(bounds[1], block_bounds[1])
				bounds[2] = max(bounds[2], block_bounds[2])
				bounds[3] = max(bounds[3], block_bounds[3])
			else:
				block_bounds = block_bounds
				init = true
	return bounds
