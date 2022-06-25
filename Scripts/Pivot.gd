# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# This script is mostly meant as an editor helper for placing
# shape rotation pivot points on a grid.

tool
extends Node2D
class_name Pivot

signal update(new_position)

export var cell = Vector2.ZERO

var grid:Grid = null

func _process(_delta):
	if Engine.editor_hint:
		# Lazy load the grid. This script only works is the parent node
		# is a Grid instance.
		if grid == null:
			grid = get_parent() as Grid
		if grid == null:
			return
			
		# Make sure the pivot position lines up with HALF grid intervals.
		var cell_position = grid.local_position_to_cell_coordinates(position)
		cell_position *= 2
		cell_position.x = round(cell_position.x)
		cell_position.y = round(cell_position.y)
		
		# However, we don't want the pivot in the middle of edges, only
		# at the corners, or in the middle of a cell.
		if int(cell_position.x) % 2 < 1 and int(cell_position.y) % 2 > 0:
			cell_position.y -= 1
		elif int(cell_position.y) % 2 < 1 and int(cell_position.x) % 2 > 0:
			cell_position.x -= 1
			
		cell_position *= 0.5
		position = grid.cell_coordinates_to_local_position(cell_position)
		
		if cell != cell_position:
			cell = cell_position
			
			# Now that the pivot is set, update each block's rotation offset.
			if is_inside_tree():
				for sibling in get_parent().get_children():
					if sibling is Block:
						var block_cell = grid.get_cell(sibling.position)
						sibling.rotation_offset =  (block_cell - cell_position) + Vector2.ONE * 0.5
						
			emit_signal("update", cell)
