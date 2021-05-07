# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends KinematicBody2D

# If this is true, the controller will update in the physics loop, otherwise it 
# updates in the main loop.
export var process_in_physics_loop = false

# The grid cell size in pixels
export var cell_size = Vector2(40, 40)

# The maximum speed in cells per second for the x and y axes
export var maximum_cells_per_second = Vector2(4, 4)

# When the player keeps a movement key press, wait for this amount of seconds
# before moving to the next cell
export var autoshift_delay = 0.5

# Gradually ease into target cell when > 0
export(float, 0.0, 0.99) var easing = 0.0

export(NodePath) var dump_target

var target_position:Vector2
var autoshift_motion = Vector2.ZERO
var autoshift_wait_time = 0

# Move by the specified number of cells
func move(x_cells:int, y_cells:int):
	var old_target_position = target_position
	target_position += Vector2(x_cells, y_cells) * cell_size
	
	var move_vertically = y_cells != 0
	var move_horizontally = x_cells != 0
	var delta_position = target_position - position
	
	if move_vertically and move_horizontally:
		var will_collide = test_move(transform, Vector2(0, delta_position.y))
		if will_collide: # Cannot move vertically
			# Let's see if we can move horizontally
			will_collide = test_move(transform, Vector2(delta_position.x, 0))
			if will_collide: # We cannot move in any direction
				target_position = old_target_position
				return false
			else: # Can move horizontally
				# Let's try moving horizontally, THEN vertically
				var virtual_transform = transform
				virtual_transform.origin += Vector2(delta_position.x, 0)
				will_collide = test_move(virtual_transform, Vector2(0, delta_position.y))
				if will_collide: # That didn't work either
					target_position = old_target_position
					return false
		else:
			# Let's try moving vertically, THEN horizontally
			var virtual_transform = transform
			virtual_transform.origin += Vector2(0, delta_position.y)
			will_collide = test_move(virtual_transform, Vector2(delta_position.x, 0))
			if will_collide: # That didn't work
				target_position.x = old_target_position.x
				return false
			
	elif move_vertically or move_horizontally:
		var will_collide = test_move(transform, delta_position)
		if will_collide:
			target_position = old_target_position
			return false
			
	return true

# Sends child blocks to the dump_target node. Deletes this node if 
# destroy_self is true.
func dump_blocks(destroy_self = true):
	# Move to target position to avoid blocks falling off the grid lines.
	position = target_position 
	if dump_target:
		var new_parent = get_node(dump_target) if dump_target is NodePath else dump_target
		for child in get_children():
			var global_transform = child.global_transform
			remove_child(child)
			new_parent.add_child(child)
			child.global_transform = global_transform
	if destroy_self:
		queue_free()
		
func set_position(new_position:Vector2):
	position = new_position
	target_position = position
	
# Due to easing, the position might not lie perfectly on a cell
# and so we need to return the target position instead here.
func get_position():
	return target_position

func _ready():
	target_position = position
	
func _rotate_node(node, theta):
	if node is Node2D:
		var l = node.position.length()
		var a = node.position.angle()
		a += theta
		var x = round(cos(a) * l / cell_size.x) * cell_size.x
		var y = round(sin(a) * l / cell_size.y) * cell_size.y
		node.position = Vector2(x, y)
	
func _rotate_blocks(theta):
	# We don't actually rotate the transform, instead we move child nodes
	# individually.
	for child in get_children():
		_rotate_node(child, theta)
	
	# After rotation, check for collisions. It is tempting to use something like:
	# var t = transform.rotated(theta)
	# var will_collide = test_move(t, Vector2.ZERO)
	# instead of actually moving the blocks as above, but for some reason this 
	# doesn't detect collisions.
	var will_collide = test_move(transform, Vector2.ZERO)
	
	if will_collide:
		# Undo the rotation
		for child in get_children():
			_rotate_node(child, -theta)
			
func _update(delta):
	# Translation
	var motion_input = Vector2.ZERO
	if Input.is_action_pressed("move_left") and maximum_cells_per_second.x > 0:
		motion_input.x += -1
	if Input.is_action_pressed("move_right") and maximum_cells_per_second.x > 0:
		motion_input.x += 1
	if Input.is_action_pressed("move_up") and maximum_cells_per_second.y > 0:
		motion_input.y += -1
	if Input.is_action_pressed("move_down") and maximum_cells_per_second.y > 0:
		motion_input.y += 1
		
	if (Input.is_action_just_pressed("move_left")
	or Input.is_action_just_pressed("move_right")
	or Input.is_action_just_pressed("move_up")
	or Input.is_action_just_pressed("move_down")) :
		autoshift_wait_time = 0
		autoshift_motion = motion_input
		move(motion_input.x, motion_input.y)
	elif motion_input.x != 0 or motion_input.y != 0:
		autoshift_wait_time += delta
		if autoshift_wait_time >= autoshift_delay:
			autoshift_motion += motion_input * maximum_cells_per_second * delta
			var quantized_motion = Vector2(int(autoshift_motion.x), int(autoshift_motion.y))
			autoshift_motion -= quantized_motion
	
			move(quantized_motion.x, quantized_motion.y)

	position = lerp(target_position, position, easing)
	
	# Rotation
	var rotation_rad = 0
	if Input.is_action_just_pressed("rotate_clockwise"):
		rotation_rad =  PI * 0.5
	elif Input.is_action_just_pressed("rotate_counterclockwise"):
		rotation_rad = PI * -0.5
	
	if rotation_rad != 0:
		_rotate_blocks(rotation_rad)
		rotation_rad = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not process_in_physics_loop:
		_update(delta)
	
func _physics_process(delta):
	if process_in_physics_loop:
		_update(delta)
