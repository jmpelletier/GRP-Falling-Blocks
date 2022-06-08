# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends "res://Scripts/RadioButtons.gd"

signal shape_selected(shape)

const SHAPE_DIRECTORY = "res://Shapes"

const Node2DContainer = preload("res://Scenes/Tools/Node2DContainer.tscn")
const BlockShape = preload("res://Scripts/Shape.gd")

var shapes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	load_shapes()

func update_shapes():
	shapes = []
	var dir = Directory.new()
	if dir.open(SHAPE_DIRECTORY) == OK:
		dir.list_dir_begin()
		var fn = dir.get_next()
		while fn != "":
			if not dir.current_is_dir():
				shapes.append(SHAPE_DIRECTORY + "/" + fn)
			fn = dir.get_next()
	return shapes
			
func load_shapes():
	# Get a list of shapes
	update_shapes()
	
	container = null
	for child in get_children():
		child.queue_free()
	
	# Change the count
	count = shapes.size()
	_layout()
		
	# Add the new shapes
	for i in shapes.size():
		var path = shapes[i]
		var new_shape = load(path).instance()
		
		var btn = container.get_child(i)
		if btn != null:
			var node_container = btn.get_node("Node2DContainer")
			if node_container != null:
				node_container.add_child(new_shape)
		
			# Adjust the offset so that the shape is centered
			if new_shape is BlockShape:
				var bounds = new_shape.get_bounds()
				var center = Vector2(bounds[0] + bounds[2], bounds[1] + bounds[3]) * 0.5
				node_container.offset = center * -1
			
			# Update the container layout
			node_container.layout()

func _on_focus(node):
	pass

func _on_focus_lost(node):
	pass
	
func _on_clicked(node):
	pass
	
func _on_select(index):
	emit_signal("shape_selected", shapes[index])
