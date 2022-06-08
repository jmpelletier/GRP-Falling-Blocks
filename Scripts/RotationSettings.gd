# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
tool
extends Resource

signal update(try, rotation)

export var tries = [
#   0->90            0->270         90->180        90->0          180->270       180->90         270->0          270->180
	[Vector2(-1,0),  Vector2(1,0),  Vector2(1,0),  Vector2(1,0),  Vector2(1,0),  Vector2(-1,0),  Vector2(-1,0),  Vector2(-1,0)],  # Try 1
	[Vector2(-1,1),  Vector2(1,1),  Vector2(1,-1), Vector2(1,-1), Vector2(1,1),  Vector2(-1,1),  Vector2(-1,-1), Vector2(-1,-1)], # Try 2
	[Vector2(0,-2),  Vector2(0,-2), Vector2(0,2),  Vector2(0,2),  Vector2(0,-2), Vector2(0,-2),  Vector2(0,2),   Vector2(0,2)],   # Try 3
	[Vector2(-1,-2), Vector2(1,-2), Vector2(1,2),  Vector2(1,2),  Vector2(1,-2), Vector2(-1,-2), Vector2(-1,2),  Vector2(-1,2)]   # Try 4
] setget set_tries

func set_tries(value) -> void:
	# Find out which try and rotation changed
	var changed_try = -1
	var changed_rotation = -1
	for i in range(tries.size()):
		if i < value.size():
			for rotation in range(tries[i].size()):
				if rotation < value[i].size():
					if value[i][rotation] != tries[i][rotation]:
						changed_try = i
						changed_rotation = rotation
						break
			
	tries = value
	emit_signal("update", changed_try, changed_rotation)
