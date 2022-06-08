# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# This script must be added to a node that is a direct child of a Grid
# instance.
#
# With this node, when the user clicks on the grid, new blocks will be
# added (or removed if shift is pressed) to the grid.
#
# This script may be useful when testing gameplay.

extends Node

const Grid = preload("res://Scripts/Grid.gd")

# This is the block that will be added to the grid.
export(PackedScene) var block

var grid:Grid = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# This script must be used on a node that is a direct
	# child of a Grid node.
	grid = get_parent() as Grid

# This private method tells the grid to add a block
# to the cell, or, if the shift key is pressed, to
# remove the block at the specified cell.
func _modify_cell(cell:Vector2) -> void:
	if grid != null and block != null:
		if Input.is_key_pressed(KEY_SHIFT):
			grid.remove_block(cell)
		else:
			if not grid.cell_is_occupied(cell):
				var new_block = block.instance()
				grid.add_block(new_block, cell)


func _on_EditableGrid_mouse_press(button, cell):
	_modify_cell(cell)


func _on_EditableGrid_mouse_drag(button, cell):
	_modify_cell(cell)
