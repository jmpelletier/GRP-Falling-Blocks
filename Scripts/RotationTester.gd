# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

export var tile:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Grid_mouse_press(button, cell):
	if button == 1:
		var item_at_cell = $Grid.get_item_at_cell(cell.x, cell.y)
		
		if Input.is_key_pressed(KEY_SHIFT): # Delete
			if item_at_cell != null:
				item_at_cell.queue_free()
		else: # Add
			if item_at_cell == null:
				$Grid.add_item_at_cell(tile.instance(), cell.x, cell.y)


func _on_Grid_mouse_drag(button, cell):
	if button == 1:
		var item_at_cell = $Grid.get_item_at_cell(cell.x, cell.y)
		
		if Input.is_key_pressed(KEY_SHIFT): # Delete
			if item_at_cell != null:
				item_at_cell.queue_free()
		else: # Add
			if item_at_cell == null:
				$Grid.add_item_at_cell(tile.instance(), cell.x, cell.y)
