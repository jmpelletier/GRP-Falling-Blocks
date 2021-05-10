# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# This script is only used to make sure that blocks are aligned with the grid.
# In this implementation, the grid cell size is not set explicitely, rather
# it is defined using a RectangleShape2D, which is also used for collision 
# detection.

tool
extends CollisionShape2D

# If the collision shape lines up perfectly with the grid, collisions will be
# registered between neighbours. To avoid this, if this parameter is true, the 
# the extents of the collision rectangle will be reduced by one pixel to fix this
# problem.
export var shrink_shape = true

# Call this function if you want to align this block on the implicit grid.
func align(offset = Vector2.ZERO):
	if shape is RectangleShape2D:
		var p = position - offset
		var size = shape.extents
		if shrink_shape and not Engine.editor_hint:
			size += Vector2.ONE
		align_to_grid(size, offset)

# Call this function if you wish to align this block to an explicit grid.
func align_to_grid(cell_size:Vector2, offset = Vector2.ZERO):
	var p = position - offset
	position = p.snapped(cell_size) + offset

func get_size():
	if shrink_shape and not Engine.editor_hint:
		return shape.extents * 2 + Vector2(2, 2)
	else:
		return shape.extents * 2

# Called when the node enters the scene tree for the first time.
func _ready():
	if shrink_shape and shape is RectangleShape2D and not Engine.editor_hint:
		shape.extents -= Vector2.ONE
