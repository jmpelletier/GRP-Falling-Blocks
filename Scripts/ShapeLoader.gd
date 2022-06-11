# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

signal cannot_place

const Block = preload("res://Scripts/Block.gd")
const Grid = preload("res://Scripts/Grid.gd")
const BlockShape = preload("res://Scripts/BlockShape.gd")
const BlockController = preload("res://Scripts/BlockController.gd")
const ShapeOutline = preload("res://Scripts/ShapeOutline.gd")

export(NodePath) var target
#export(NodePath) var outline_container
export(Vector2) var spawn_cell = Vector2.ZERO
export(Array, PackedScene) var shapes


# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("load_shape", 0)
#	load_shape(0)
	

func load_shape(index:int) -> void:
	if index >= 0 and index < shapes.size() and shapes[index] != null:
		var shape_instance = shapes[index].instance()
		# Get all the blocks and move them to the target.
		# If the target is null, send to self
		var send_to = get_node(target)
		if send_to == null:
			send_to = self
			
		# If the shape instance is a Grid, use its functionality
		var from_grid = shape_instance as Grid
		
		# Same thing for target
		var to_grid = send_to as Grid
		var to_controller = send_to as BlockController
		if to_grid == null and to_controller != null:
			to_grid = to_controller.get_grid()
		
		# Check that all blocks can be placed
		var can_place = true
		for child in shape_instance.get_children():
			if child is Block:
				if from_grid != null and to_grid != null:
					var from_cell = from_grid.get_cell(child.position) + from_grid.offset
					var to_cell = from_cell + spawn_cell
					if to_grid.cell_is_occupied(to_cell):
						can_place = false
						break
						
		if not can_place:
			print("Cannot place!")
			emit_signal("cannot_place")
		else:
			# Try to copy the rotation settings and shape outline
			if shape_instance is BlockShape and send_to is BlockController:
				send_to.kicks = shape_instance.get_kicks()
				var outline := shape_instance.get_outline() as ShapeOutline
				if outline != null:
					send_to.set_outline(outline)
					outline.init_outline(shape_instance)
					
			# Reparent only the blocks
			for child in shape_instance.get_children():
				if child is Block:
					if from_grid != null and to_grid != null:
						var from_cell = from_grid.get_cell(child.position) + from_grid.offset
						var to_cell = from_cell + spawn_cell
						shape_instance.remove_child(child)
						if to_controller != null:
							to_controller.add_block(child, to_cell)
						else:
							to_grid.add_block(child, to_cell)
					else:
						# Can't use grids, just reparent the node
						shape_instance.remove_child(child)
						send_to.add_child(child)
#					var outline = child.get_outline()
#					if outline != null:
##						if outline.get_parent() != null:
##							outline.get_parent().remove_child(outline)
##						get_node(outline_container).add_child(outline)
#						outline.global_position = child.global_position

		# Release the shape template
		shape_instance.queue_free()
