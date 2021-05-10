# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# This script is meant to be used in the editor only. You do not need to run this
# scene. When you change the shape parameter in the inspector, this script will
# display its rotation and kicking behaviour.

tool
extends Node2D

const KickSettings = preload("res://Scripts/KickSettings.gd")
const Block = preload("res://Scripts/Block.gd")

const grid = preload("res://Scenes/Demos/Utils/RotationDemoGrid.tscn") 
const origin_marker = preload("res://Scenes/Demos/Utils/OriginMarker.tscn")
const pivot_marker = preload("res://Scenes/Demos/Utils/RotationPivotMarker.tscn")
const block = preload("res://Scenes/Block.tscn")

export var shape:PackedScene

export var spacing = Vector2(360, 360)

export var from_color = Color.green
export var to_color = Color.red

var current_resourcepath = null

var angles = [0, 90, 180, -90]

func _clear():
	for child in $StartRotations.get_children():
		child.queue_free()
		
	for child in $TargetRotations.get_children():
		child.queue_free()
		
	for child in $Kicks.get_children():
		child.queue_free()	

func _rotate_node(node, theta, rotation_pivot):
	if node is Node2D:
		var p = node.position - rotation_pivot
		var l = p.length()
		var a = p.angle()
		a += theta
		var x = cos(a) * l + rotation_pivot.x
		var y = sin(a) * l + rotation_pivot.y
		node.position = Vector2(x, y)
		if node is Block:
			node.align()
	
func _rotate_blocks(owner, theta, rotation_pivot):
	# We don't actually rotate the transform, instead we move child nodes
	# individually.
	var children = owner.get_children()
	for child in children:
		_rotate_node(child, theta, rotation_pivot)
		
func _find_node(parent:Node, names:Array):
	var node = null
	for name in names:
		node = parent.find_node(name, false)
		if node:
			break
	return node
		
func _get_rotation_pivot(node:Node2D):
	var pivot = _find_node(node, ["Pivot", "pivot"])
	if pivot:
		return pivot.position
	else:
		return Vector2.ZERO
			
func _get_kick_settings(node:Node2D, from_angle, to_angle):
	var settings_node = _find_node(node, ["Kick", "kick"])
	if settings_node and settings_node is KickSettings:
		return settings_node.get_settings(from_angle, to_angle)
	return null
		

func _rotation_view(index, angle, color):
	var container = Node2D.new()
	container.position = Vector2.DOWN * index * spacing.y
	container.add_child(grid.instance())
	
	var shape_obj = shape.instance()
	var pivot_point = _get_rotation_pivot(shape_obj)
	container.add_child(shape_obj)
	_rotate_blocks(shape_obj, angle * PI / 180, pivot_point)
	shape_obj.modulate = color
	
	var pivot = pivot_marker.instance()
	container.add_child(pivot)
	pivot.position += pivot_point
	container.add_child(origin_marker.instance())
	
	return container
	
func _guess_cell_size(shape_node:Node2D):
	for child in shape_node.get_children():
		if child is Block:
			return child.get_size()
			
	return Vector2(40, 40)
	
func _get_block_positions(node:Node2D, offset = Vector2.ZERO):
	var positions = []
	for child in node.get_children():
		if child is Block:
			positions.push_back(child.position + offset)
	return positions
	
func _block_set_complement(a:Array, b:Array):
	var ret = []
	for p_a in a:
		var has_duplicate = false
		for p_b in b:

			if p_a.distance_to(p_b) < 3:
				has_duplicate = true
				break
		if not has_duplicate:
			ret.push_back(p_a)
	return ret
	
func _kick_view(index, from_angle, to_angle):
	var shape_obj = shape.instance()
	var outer_container = Node2D.new()
	outer_container.position = Vector2.DOWN * index * spacing.y
	var kick_settings = _get_kick_settings(shape_obj, from_angle, to_angle)
	if kick_settings:
		var i = 0
		var cell_size = _guess_cell_size(shape_obj)
		var pivot_point = _get_rotation_pivot(shape_obj)

		var open_color = from_color
		var closed_color = to_color
		var new_closed_color = to_color
		open_color.a = 0.2
		closed_color.a = 0.2
		new_closed_color.a = 0.3
		
		var from_shape = shape.instance()
		_rotate_blocks(from_shape, from_angle * PI / 180, pivot_point)
		var to_shape = shape.instance()
		_rotate_blocks(to_shape, to_angle * PI / 180, pivot_point)
		var open_blocks = _get_block_positions(from_shape)
		var new_closed_blocks = _block_set_complement(_get_block_positions(to_shape), open_blocks)
		var closed_blocks = []
		
		for kick in kick_settings:
			var container = Node2D.new()
			container.position = Vector2.RIGHT * i * spacing.x
			container.add_child(grid.instance())
			outer_container.add_child(container)
		
			for p in open_blocks:
				var b = block.instance()
				b.position = p
				b.modulate = open_color
				container.add_child(b)
				
			for p in new_closed_blocks:
				var b = block.instance()
				b.position = p
				b.modulate = new_closed_color
				container.add_child(b)
				
			for p in closed_blocks:
				var b = block.instance()
				b.position = p
				b.modulate = closed_color
				container.add_child(b)
				
			if shape_obj == null:
				shape_obj = shape.instance()
				
			container.add_child(shape_obj)
			
			_rotate_blocks(shape_obj, to_angle * PI / 180, pivot_point)
			
			shape_obj.position = kick * cell_size
			
			closed_blocks += new_closed_blocks
			
			new_closed_blocks = _block_set_complement(_block_set_complement(_get_block_positions(shape_obj, kick * cell_size), open_blocks), closed_blocks)
			
			container.add_child(origin_marker.instance())
			shape_obj = null
			i += 1
	return outer_container


func _add_views(index, from_angle, to_angle):
	$StartRotations.add_child(_rotation_view(index, from_angle, from_color))
	$TargetRotations.add_child(_rotation_view(index, to_angle, to_color))
	$Kicks.add_child(_kick_view(index, from_angle, to_angle))

func _update():
	if shape and shape.resource_path != current_resourcepath:
		_clear()
		var count = 0
		for a1 in angles:
			for a2 in angles:
				if abs(a1 - a2) == 90 or abs(a1 - a2) == 270:
					_add_views(count, a1, a2)
					count += 1
		
		current_resourcepath = shape.resource_path

# Called when the node enters the scene tree for the first time.
func _ready():
	_update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update()
