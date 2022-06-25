# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends Node2D

export var target_rotation = 0 setget set_target_rotation

export var grid_size = Vector2(6,6)
export(PackedScene) var grid_scene
export(PackedScene) var arrow_scene
export(PackedScene) var from_block 
export(PackedScene) var to_block
export(PackedScene) var kick_block
export(PackedScene) var open_block
export(PackedScene) var collision_block

const rotations = [Transform2D(), Transform2D(PI * 0.5, Vector2.ZERO), Transform2D(PI, Vector2.ZERO), Transform2D(PI * -0.5, Vector2.ZERO)]
const from_rotations = [0, 0, 1, 1, 2, 2, 3, 3]
const to_rotations = [1, 3, 2, 0, 3, 1, 0, 2]
const labels = [[0,90],[0,-90],[90,180],[90,0],[180,-90],[180,90],[-90,0],[-90,180]]

var last_kick_grid:Node2D = null
var rotation_settings:RotationSettings = null

func set_target_rotation(index:int) -> void:
	if index < 0:
		target_rotation = (index % 8) + 8
	else:
		target_rotation = index % 8
	_layout()
	
func _resize_sprite(sprite:Sprite, size:Vector2) -> void:
	sprite.scale = size / sprite.texture.get_size()

func _place_grid_beside(grid:Grid, neighbor:Grid) -> void:
	var new_position = Vector2.ZERO
	if neighbor != null:
		var x_offset = (neighbor.size.x + 1) * neighbor.cell_size.x
		new_position = neighbor.position + Vector2(x_offset, 0)
	else:
		new_position = grid.offset * grid.cell_size * -1.0
	grid.position = new_position
	
func _copy_blocks(source_grid:Grid, target_grid:Grid, block_scene:PackedScene) -> void:
	var block_control = target_grid.get_node_or_null("BlockController") as BlockController
	if source_grid != null  and block_scene != null:
		for node in source_grid.get_children():
			if node is Block:
				var cell = source_grid.get_cell(node.position)
				var relative_cell = cell + source_grid.offset
				var target_cell = relative_cell - target_grid.offset
				var new_block = block_scene.instance() as Block
				new_block.rotation_offset = node.rotation_offset
				if block_control != null:
#					block_control.add_block_at_cell(new_block, target_cell)
					block_control.add_block(new_block, target_cell)
				else:
					target_grid.add_block(new_block, target_cell)
				
func _rotate_blocks(target_grid:Grid, transform_index:int) -> void:
	var block_control = target_grid.get_node_or_null("BlockController") as BlockController
	if block_control != null:
		block_control.rotate_blocks(rotations[transform_index])
		
# Returns an array containing only the elements of 'a' that are not in 'b'.
func _array_diff(a:Array, b:Array) -> Array:
	var diff = []
	for el_a in a:
		var found = false
		for el_b in b:
			if el_b == el_a:
				found = true
				break
		if not found:
			diff.push_back(el_a)
	return diff

func _show_pivot(target_grid:Grid) -> void:
	# Get the pivot in parent
	var pivot = get_node_or_null("../Pivot") as Pivot
	var parent_grid = get_parent() as Grid
	var pivot_marker = target_grid.get_node_or_null("PivotMarker") as Sprite
	if pivot != null and parent_grid != null and pivot_marker != null:
		var cell = pivot.cell + parent_grid.offset - target_grid.offset - Vector2.ONE * 0.5
		_resize_sprite(pivot_marker, target_grid.cell_size * 0.75)
		pivot_marker.position = target_grid.get_cell_position(cell)
		
func _add_cell_markers(target_grid:Grid, cells:Array, scene:PackedScene) -> void:
	for cell in cells:
		var marker = scene.instance()
		_resize_sprite(marker, target_grid.cell_size)
		target_grid.add_child(marker)
		marker.position = target_grid.get_cell_position(cell - target_grid.offset)
		
func _setup_kick_grids() -> void:
	# Clear the previous grids
	for child in $KickGrids.get_children():
		$KickGrids.remove_child(child)
		child.queue_free()
		
	last_kick_grid = null
	
	# List of cells that must be free (or open)
	var open_cells = $FromGrid.get_occupied_cells(true)
	
	# List of cells that might be occupied and block the rotation
	var collision_cells = _array_diff($ToGrid.get_occupied_cells(true), open_cells)

	var try_count = 0
	if rotation_settings != null and grid_scene != null:
		for rotations in rotation_settings.tries:
			try_count += 1
			
			var new_grid = grid_scene.instance() as Grid
			new_grid.offset = $FromGrid.offset
			new_grid.size = $FromGrid.size
			new_grid.cell_size = $FromGrid.cell_size
			$KickGrids.add_child(new_grid)
			
			if last_kick_grid == null:
				_place_grid_beside(new_grid, $ToGrid)
			else:
				_place_grid_beside(new_grid, last_kick_grid)
				
			# Add the blocks
			_copy_blocks($ToGrid, new_grid, kick_block)
			
			# Move the blocks
			var control = new_grid.get_node_or_null("BlockController") as BlockController
			if control != null:
				control.move(rotations[target_rotation])
				
			# Mark the cells that must be open
			_add_cell_markers(new_grid, open_cells, open_block)
			
			# Mark the collisions
			_add_cell_markers(new_grid, collision_cells, collision_block)
			
			# Find new potential collisions
			var collisions = _array_diff(new_grid.get_occupied_cells(true), open_cells)
			collision_cells += _array_diff(collisions, collision_cells)
				
			# Draw the translation arrow
			var arrow = arrow_scene.instance()
			new_grid.add_child(arrow)
			arrow.from = Vector2.ZERO
			arrow.to = rotations[target_rotation] * new_grid.cell_size
			arrow.set_modulate(Color.red)
			arrow.z_index = 1000
			
			# Add the label
			var label = EditorLabel.instance()
			label.text = "Try " + str(try_count) + ": " + str(rotations[target_rotation])
			new_grid.add_child(label)
			label.rect_position = Vector2.DOWN * (new_grid.size.y + 1) * new_grid.cell_size.y + new_grid.offset * new_grid.cell_size
			
			last_kick_grid = new_grid

func _layout() -> void:

	# Remove all blocks
	$FromGrid/BlockController.clear_blocks()
	$ToGrid/BlockController.clear_blocks()
	
	# Resize both grids and center their offsets.
	$FromGrid.size = grid_size
	$FromGrid.offset = Vector2(int(grid_size.x * -0.5), int(grid_size.y * -0.5))
	$ToGrid.size = grid_size
	$ToGrid.offset = $FromGrid.offset
	
	# Now place the grids size-by-side
	_place_grid_beside($FromGrid, null)
	_place_grid_beside($ToGrid, $FromGrid)
	
	# Adjust the labels
	$FromLabel.rect_position = $FromGrid.position + Vector2.DOWN * $FromGrid.cell_size.y * ($FromGrid.size.y + 1) + $FromGrid.offset * $FromGrid.cell_size
	$ToLabel.rect_position = $ToGrid.position + Vector2.DOWN * $ToGrid.cell_size.y * ($ToGrid.size.y + 1) + $ToGrid.offset * $ToGrid.cell_size
	
	# Change the label text
	$FromLabel.text = "From: " + str(labels[target_rotation][0])
	$ToLabel.text = "To: " + str(labels[target_rotation][1])
	if target_rotation % 2 == 0:
		$ToLabel.text += " (clockwise)"
	else:
		$ToLabel.text += " (counter-clockwise)"
	
	# Load the blocks
	_copy_blocks(get_parent(), $FromGrid, from_block)
	_copy_blocks(get_parent(), $ToGrid, to_block)

	# Rotate the blocks
	_rotate_blocks($FromGrid, from_rotations[target_rotation])
	_rotate_blocks($ToGrid, to_rotations[target_rotation])
	
	# Add or resize the kick grids
	_setup_kick_grids()
	
	# Move the pivot marker
	_show_pivot($FromGrid)
	_show_pivot($ToGrid)

func _rotation_settings_changed(try, rotation) -> void:
	if (rotation >= 0):
		target_rotation = rotation
	_layout()

func _pivot_changed(new_position:Vector2) -> void:
	_layout()

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		# Get the pivot in parent
		var pivot = get_node_or_null("../Pivot") as Pivot
		if pivot != null and not pivot.is_connected("update", self, "_pivot_changed"):
			pivot.connect("update", self, "_pivot_changed", [], CONNECT_PERSIST)
		_layout()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Engine.editor_hint:
		# Try to get the rotation settings
		var block_shape = get_parent() as BlockShape
		
		# Check to see if the settings have changed
		if block_shape != null:
			var settings = block_shape.rotation_settings as RotationSettings
			if settings != rotation_settings:
				# Settings have changed, disconnect signals from previous settings.
				if settings != null and settings.is_connected("update", self, "_rotation_settings_changed"):
					settings.disconnect("update", self, "_rotation_settings_changed")
				
				# Update the settings, connect signals and redo the layout
				rotation_settings = settings
				rotation_settings.connect("update", self, "_rotation_settings_changed", [], CONNECT_PERSIST)
				_layout()
		
		# If the grid size has changed, redo the layout
		if $FromGrid.size != grid_size or $ToGrid.size != grid_size:
			_layout()
