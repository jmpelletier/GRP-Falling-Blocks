# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends Node2D

# This signal is sent when there is a succesful 'kick'.
signal rotation_kick(rotation_index, try_index)

# This signal is sent when a piece is locked in place.
signal blocks_placed

# This signal is sent when the piece is succesfully moved by the player.
signal blocks_moved(line_change)

# This signal is sent when the piece is succesfully rotated by the player.
signal blocks_rotated(line_change)

# This signal is sent when a 'hard drop' is succesfully perfomed by the player.
signal hard_drop(motion)

# Preload the necessary classes
const Block = preload("res://Scripts/Block.gd")
const Grid = preload("res://Scripts/Grid.gd")
const BlockShape = preload("res://Scripts/BlockShape.gd")
const ShapeOutline = preload("res://Scripts/ShapeOutline.gd")

# If this is true, this node allows the user to control the blocks.
# Turn this off if you want to only control the blocks programatically.
export var accept_user_input = true

# If this is true, the controller will update in the physics loop, otherwise it 
# updates in the main loop.
export var process_in_physics_loop = false

# The maximum speed in cells per second for the x and y axes.
export var maximum_cells_per_second = Vector2(4, 4)

# The rotation speed in quarter-turns per second.
export var autorotate_speed = 4

# When the player keeps a movement key press, wait for this amount of seconds
# before moving to the next cell.
export var autoshift_delay = 0.5

# The same as autoshift_delay but for rotation.
export var autorotate_delay = 0.5

var kicks = []

var parent_grid:Grid = null
var blocks = []
var shape_outline = null 
var autoshift_motion = Vector2.ZERO
var autoshift_wait_time = 0
var autorotate_wait_time = 0

var position_offset = Vector2.ZERO

# The orientation is coded as follows:
# 0: Default orientation
# 1: Rotated 90 degrees clockwise
# 2: Rotated 180 degrees
# 3: Rotated 90 degrees counter-clockwise
var orientation:int = 0

func _lazy_load_grid() -> bool:
	if parent_grid == null:
		parent_grid = get_parent() as Grid
		if parent_grid != null and not parent_grid.is_connected("block_removed", self, "_on_block_removed"):
# warning-ignore:return_value_discarded
			parent_grid.connect("block_removed", self, "_on_block_removed")
	return parent_grid != null

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.editor_hint:
		for child in get_children():
			if child is Block:
				call_deferred("add_block", child)

# Removes all the blocks under control from the scene.
func clear_blocks() -> void:
	if _lazy_load_grid():
		for block in blocks:
			parent_grid.remove(block)
	release_blocks()
			
func release_blocks() -> void:
	blocks.clear()
	
func reset_movement() -> void:
	position_offset = Vector2.ZERO
	
func get_grid() -> Grid:
# warning-ignore:return_value_discarded
	_lazy_load_grid()
	return parent_grid

# This methods adds a block to the list of nodes under control.
# The block will be reparented to the grid.
# If there is already a block at the same position, nothing happens.
func add_block(block:Block, cell:Vector2) -> void:
	if _lazy_load_grid() and block != null:
		if not parent_grid.cell_is_occupied(cell):
			if block.is_inside_tree() and block.get_parent() != null:
				block.get_parent().remove_child(block)
			parent_grid.add_block(block, cell)
			blocks.push_back(block)
			# Tell the block it's now under control
			block.control()

# This method initializes the shape outline, or 'ghost' that
# previews where hard drops will fall. This is called by the 
# ShapeLoader every time a new shape is loaded into the field.
func set_outline(outline:ShapeOutline) -> void:
	if outline == shape_outline:
		return
		
	if shape_outline != null:
			shape_outline.queue_free()
			shape_outline = null
			
	if _lazy_load_grid() and outline != null:
		shape_outline = outline
		shape_outline.get_parent().remove_child(shape_outline)
		parent_grid.add_child(outline)
		outline.show()

# Signal callback: a block was removed from the parent grid.
# We need to check and update the list of blocks that are under
# our control.
func _on_block_removed(block:Node2D, _cell:Vector2) -> void:
	for i in range(blocks.size()):
		if blocks[i] == block:
			blocks.remove(i)
			break

# This is a helper function that is used for detection collisions.
func _cell_is_empty_or_under_control(cell:Vector2) -> bool:
	if parent_grid.cell_is_in_bounds(cell):
		var existing_block = parent_grid.get_block_at_cell(cell)
		if existing_block != null:
			var under_control = false
			for block in blocks:
				if block == existing_block:
					under_control = true
					break
			return under_control
		else:
			return true
	
	# Return false if cell is out of bounds
	return false

# Checks whether a rotation can be performed without collisions.
func _can_rotate(transform2D:Transform2D, translation:Vector2) -> bool:
	for block in blocks:
		var new_offset = transform2D.xform(block.rotation_offset)
		var delta = new_offset - block.rotation_offset
		var old_cell = parent_grid.get_cell(block.position)
		var new_cell = old_cell + delta + translation
		if not _cell_is_empty_or_under_control(new_cell):
			return false
	return true
		
# Rotate the blocks around the pivot.	
func rotate_blocks(transform2D:Transform2D) -> bool:
	
	# We can tell if we are rotating clockwise or counter-clockwise,
	# by looking at the x-basis of the transform. Note that this only
	# works for 90-degree rotations.
	var new_orientation = int(orientation + transform2D.x.y) % 4
	if new_orientation < 0:
		new_orientation += 4
	var orientation_diff = new_orientation - orientation
	var rotation_index = orientation * 2
	if orientation_diff == -1 or orientation_diff == 3:
		rotation_index += 1
	
	# If a rotation cannot be performed because a block is in the way,
	# we try a number of succesive translation before the rotation.
	# This is known as 'kicking' and every shape can have its own
	# translations, or 'kicks'.
	var kick_offset = Vector2.ZERO
	var did_kick = false
	var kick_rotation_index = 0
	var kick_tries = 0
	var can_rotate = _can_rotate(transform2D, kick_offset)
	if not can_rotate:
		# Try 'kicking' the shape
		var try_count = kicks.size()
		for i in range(try_count):
			if kicks[i] is Array and kicks[i][rotation_index] != null:
				kick_offset = kicks[i][rotation_index]
				can_rotate = _can_rotate(transform2D, kick_offset)
				if can_rotate:
					did_kick = true
					kick_rotation_index = rotation_index
					kick_tries = i
					break
		
	if can_rotate:
		# Before we can rotate the blocks, we need to release them from 
		# the grid's control so that they don't collide against each other.
		for block in blocks:
			var cell = parent_grid.get_cell(block.position)
			parent_grid.release_block(cell)
		
		# Now we can move the blocks to their new position.
		for block in blocks:
			var new_offset = transform2D.xform(block.rotation_offset)
			var delta = new_offset - block.rotation_offset
	
			var old_cell = parent_grid.get_cell(block.position)
			var new_cell = old_cell + delta + kick_offset
			parent_grid.add_block(block, new_cell)
			
			# Don't forget to update the block's rotation offset.
			block.rotation_offset = new_offset
			
		# Store the new orientation
		orientation = new_orientation
		
		# Recalculate the outline
		if shape_outline != null:
			shape_outline.update_corners(blocks, parent_grid.cell_size)
	
	if did_kick:
		emit_signal("rotation_kick", kick_rotation_index, kick_tries)
		
	return can_rotate

# Find out how far, in cell units, we can move the block without
# hitting something or going out of bounds.
func maximum_movement(direction:Vector2) -> Vector2:
	var offset = parent_grid.size
	for block in blocks:
		var cell = parent_grid.get_cell(block.position)
		var block_offset = Vector2.ZERO
		while parent_grid.cell_is_in_bounds(cell + block_offset + direction):
			if not _cell_is_empty_or_under_control(cell + block_offset + direction):
				break
			else:
				block_offset += direction
		
		offset.x = min(offset.x, block_offset.x)
		offset.y = min(offset.y, block_offset.y)
	return offset

# Checks whether the translation, in cells, is possible without collision.
func can_move(movement:Vector2) -> bool:
	for block in blocks:
		var cell = parent_grid.get_cell(block.position)
		var new_cell = cell + movement
		if not _cell_is_empty_or_under_control(new_cell):
			return false
			
	return true
	
# Tries to move the blocks and checks that the operation was succesful
func try_move(input:Vector2) -> bool:
	if input.length_squared() > 0:
		return move(input) != Vector2.ZERO
	else:
		return true
			
# Move the blocks that are under control by the number of cells on the grid
# specified in the input parameter. This method checks for collisions and
# keeps the blocks inside the grid's bounds.
func move(input:Vector2) -> Vector2:
	if input.length_squared() > 0:
		# Make sure we can move all blocks
		var can_move_blocks = can_move(input)
				
		if not can_move_blocks:
			# Try to limit the movement
			while abs(input.x) > 1 and not can_move_blocks:
				input.x -= sign(input.x)
				can_move_blocks = can_move(input)
			while abs(input.y) > 1 and not can_move_blocks:
				input.y -= sign(input.y)
				can_move_blocks = can_move(input)
			if not can_move_blocks:
				return Vector2.ZERO
			
		# Before we can move the blocks, we need to release them from 
		# the grid's control so that they don't collide against each other
		# when moving
		for block in blocks:
			var cell = parent_grid.get_cell(block.position)
			parent_grid.release_block(cell)
		
		# Now we can move the blocks to their new location
		for block in blocks:
			var cell = parent_grid.get_cell(block.position)
			var new_cell = cell + input
			parent_grid.add_block(block, new_cell)
		
		# We must also move the shape outline
		if shape_outline != null:
			pass
		
		# Update the movement offset so that we know by how much we moved
		# since the last reset.
		position_offset += input
		
	return input

# 'Place', or 'lockdown' the blocks on the field, relinquishing control.
func place_blocks():
	for block in blocks:
		block.place()
	blocks.clear()
	
	# Also get rid of the outline
	if shape_outline != null:
		shape_outline.hide() 
		
	emit_signal("blocks_placed")	

# Get the y value, in cell units, of the lowest block in our control.
func _get_line() -> int:
	var line = -1
	
	for block in blocks:
		var cell = parent_grid.get_cell(block.position)
		if cell.y > line:
			line = cell.y
		
	return line

# Update the game state. This is called at every frame.
func _update(_time_seconds, delta_seconds) -> void:
	if not _lazy_load_grid():
		return
		
	if not accept_user_input:
		return
	
	# Under some rules, time to lockdown is increased only if the shape
	# has move downwards after player action. Here we get the row of the
	# lowest block in our control before we process user input.
	var start_line = _get_line()
	
	# Translation
	var move_success = false
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
		
		# We move along the y axis first, and then along the x axis.
		# This is so that collisions only block the movement along
		# axes that are constrained.
		move_success = try_move(Vector2(0, motion_input.y))
		move_success = try_move(Vector2(motion_input.x, 0)) or move_success
	
	# Process auto-shift.
	elif motion_input.x != 0 or motion_input.y != 0:
		autoshift_wait_time += delta_seconds
		if autoshift_wait_time >= autoshift_delay:
			autoshift_motion += motion_input * maximum_cells_per_second * delta_seconds
			var quantized_motion = Vector2(int(autoshift_motion.x), int(autoshift_motion.y))
			autoshift_motion -= quantized_motion
			
			move_success = try_move(Vector2(0, quantized_motion.y)) or move_success
			move_success = try_move(Vector2(quantized_motion.x, 0)) or move_success
			
	# Rotation
	var transform2D = Transform2D()
	var should_autorotate = false
	var rotation_sucess = false
	if Input.is_action_just_pressed("rotate_clockwise"):
		transform2D.x = Vector2(0, 1)
		transform2D.y = Vector2(-1, 0)
		autorotate_wait_time = 0
		rotation_sucess = rotate_blocks(transform2D)
	elif Input.is_action_just_pressed("rotate_counterclockwise"):
		transform2D.x = Vector2(0, -1)
		transform2D.y = Vector2(1, 0)
		autorotate_wait_time = 0
		rotation_sucess = rotate_blocks(transform2D)
	elif Input.is_action_pressed("rotate_clockwise"):
		transform2D.x = Vector2(0, 1)
		transform2D.y = Vector2(-1, 0)
		should_autorotate = true
	elif Input.is_action_pressed("rotate_counterclockwise"):
		transform2D.x = Vector2(0, -1)
		transform2D.y = Vector2(1, 0)
		should_autorotate = true

	# Process auto-rotate.
	if should_autorotate:
		autorotate_wait_time += delta_seconds
		if autorotate_wait_time >= autorotate_delay:
			rotation_sucess = rotate_blocks(transform2D) or rotation_sucess
			if autorotate_delay > 0:
				autorotate_wait_time -= 1.0 / autorotate_speed
				
	# We now update the outline position
	var outline_offset = maximum_movement(Vector2.DOWN)
	var outline_offset_pixels = outline_offset * parent_grid.cell_size
	
	for block in blocks:
		block.place_outline(outline_offset_pixels)
		
	# We can now check for hard drops. Soft drops are implemented in BlockGravity,
	# as they only change the speed at which blocks fall.
	if Input.is_action_just_pressed("drop"):
		move_success = try_move(outline_offset)
		
		# This should alway be succesful:
		if move_success:
			Logger.log_event("hard_drop", "(" + String(outline_offset.x) + "," + String(outline_offset.y) + ")")
			emit_signal("hard_drop", outline_offset)
			
			# On a hard drop, we place the blocks immediately.
			# If you wish to wait for the usual lockdown time instead, remove
			# this code block.
			place_blocks()
			return
	
	# We check the lowest row again.
	var end_line = _get_line()
	
	if move_success:
		emit_signal("blocks_moved", end_line - start_line)
	if rotation_sucess:
		emit_signal("blocks_rotated", end_line - start_line)	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Engine.editor_hint:
		# This node is assumed to be the child of a Grid.
		if _lazy_load_grid():
			# Align on the grid
			var cell = parent_grid.get_cell(position)
			position = parent_grid.get_cell_position(cell)
