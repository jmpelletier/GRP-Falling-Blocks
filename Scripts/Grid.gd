# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends Node2D

signal mouse_press(button, cell)
signal mouse_drag(button, cell)
signal mouse_release(button, cell)
signal block_removed(block, cell)

const GridItem = preload("res://Scripts/GridItem.gd")

const Block = preload("res://Scripts/Block.gd")

export(Vector2) var size = Vector2(10, 10) setget set_size
export(Vector2) var cell_size = Vector2(40, 40) setget set_cell_size
export(Vector2) var offset = Vector2.ZERO setget set_offset
export(int) var margin_top = 4 setget set_margin_top
export(bool) var hide_margin = false


var rows = []
var block_coordinates = []

func _update_rows():
	clear_blocks()
	rows.resize(size.y)
	for i in range(size.y):
		if not rows[i] is Array:
			rows[i] = []
		rows[i].resize(size.x)

func set_margin_top(value:int):
	margin_top = int(max(value, 0))
	
	_update_rows()
	_update()

func set_size(value:Vector2):
	size = value
	size.x = int(max(1, size.x)) 
	size.y = int(max(1, size.y))
	
	_update_rows()
	_update()
		
func set_cell_size(value:Vector2):
	cell_size = value
	_update()
	
func set_offset(value:Vector2):
	offset = value
	for child in get_children():
		_constrain_item(child)
	_update()

func _get_block(cell:Vector2):
	return rows[int(cell.y)][int(cell.x)]

func _set_block(cell:Vector2, value):
	rows[int(cell.y)][int(cell.x)] = value
	
func coords_are_in_bounds(x:int, y:int) -> bool:
	return x >= 0 and x < size.x and y >= 0 and y < size.y
	
func cell_is_in_bounds(cell:Vector2) -> bool:
	return coords_are_in_bounds(int(cell.x), int(cell.y))
	
func _get_block_at_cell(cell:Vector2) -> Node2D:
	if not cell_is_in_bounds(cell):
		return null
	return _get_block(cell)
	
func cell_is_occupied(cell:Vector2) -> bool:
	if not cell_is_in_bounds(cell):
		return false
	
	return _get_block(cell) != null
	
func get_block_cell(block:Block) -> Vector2:
	if block != null and block.get_parent() == self:
		var cell = get_cell(block.position)
		if _get_block(cell) == block:
			return cell
	return Vector2.ONE * -1

func get_cell_position(cell:Vector2) -> Vector2:
	if not cell_is_in_bounds(cell):
		return Vector2.ONE * -1
	return (cell + offset) * cell_size + cell_size * 0.5
	
func get_block_at_cell(cell:Vector2) -> Node2D:
	if cell_is_in_bounds(cell):
		return _get_block(cell)
	return null
	
func get_occupied_cells(relative_coords:bool = false) -> Array:
	var arr = []
	for i in range(rows.size()):
		for j in range(rows[i].size()):
			if rows[i][j] != null:
				if relative_coords:
					arr.push_back(Vector2(j, i) + offset)
				else:
					arr.push_back(Vector2(j, i))
	return arr

# Check to see if all the cells in a row are occupied.
func row_is_completed(row:int) -> bool:
	if row >= 0 and row < rows.size():
		for i in range(rows[row].size()):
			if rows[row][i] == null:
				return false
		return true
	else:
		return false
		
# Get a list of completed rows.
func get_completed_rows() -> Array:
	var arr = []
	for i in range(rows.size()):
		var has_empty_cells = false
		for j in range(rows[i].size()):
			if rows[i][j] == null:
				has_empty_cells = true
				break
		if not has_empty_cells:
			arr.push_back(rows[i])
	return arr

# Add a block to the grid. If the cell is already occupied,
# nothing happens.
func add_block(block:Block, cell:Vector2) -> void:
	if block == null or not cell_is_in_bounds(cell):
		return
	
	if not block.is_inside_tree() or not block.get_parent() == self:
		add_child(block)
		
	block.position = get_cell_position(cell)
	_set_block(cell, block)
	
	if block is Block:
		block.set_cell_size(cell_size)

	if hide_margin:
		block.visible = cell.y >= margin_top
		
		
func _delete_block(i:int, j:int):
	if rows[i][j] != null:
		emit_signal("block_removed", rows[i][j], Vector2(j, i))
		rows[i][j].queue_free()
		rows[i][j] = null

# Remove all blocks from the grid.
func clear_blocks() -> void:
	for i in range(rows.size()):
		for j in range(rows[i].size()):
			_delete_block(i, j)

# Remove the block at the specified cell. If the cell is not
# occupied, nothing happens.
func remove_block(cell:Vector2) -> void:
	if cell_is_in_bounds(cell):
		_delete_block(int(cell.y), int(cell.x))
		
# This method removes the block from the list of blocks
# under control but leaves it in the node tree.
# This is useful when moving blocks or when reparenting.
func release_block(cell:Vector2) -> void:
	var block = _get_block_at_cell(cell)
	if block != null:
		_set_block(cell, null)

# Remove the block from the grid.
func remove(block:Node2D, shift_cells:bool = false, shift_direction:Vector2 = Vector2.UP) -> void:
	if block != null and block.get_parent() == self:
		var cell = get_cell(block.position)
		if _get_block(cell) == block:
			_set_block(cell, null)
			remove_child(block)
			block.queue_free()
			
			if shift_cells:
				var dx = int(shift_direction.x)
				var dy = int(shift_direction.y)
				var to_x = int(cell.x)
				var to_y = int(cell.y)
				var x = to_x + dx
				var y = to_y + dy
				while coords_are_in_bounds(x, y) and coords_are_in_bounds(to_x, to_y):
					rows[to_y][to_x] = rows[y][x]
					if rows[to_y][to_x] != null:
						rows[to_y][to_x].position += cell_size * shift_direction * -1
					x += dx
					y += dy
					to_x += dx
					to_y += dy 

func get_item_at_cell(column:int, row:int):
	for child in get_children():
		if child is GridItem:
			var cell = get_cell(child.position)
			if cell.x == column and cell.y == row:
				return child
	return null
	
func add_item_at_cell(item:Node2D, column:int, row:int):
	if item is GridItem:
		add_child(item)
		item.position = Vector2(clamp(column, 0, size.x -1), clamp(row, 0, size.y -1)) * cell_size

# Given world pixel coordinates, return local pixel coordinates.
func _get_local_position(world_position:Vector2) -> Vector2:
	return transform.affine_inverse().basis_xform(world_position - transform.get_origin())

# Given local pixel coordinates, return the corresponding grid cell coordinates.
func get_cell(local_position:Vector2) -> Vector2:
	var cell_coords = local_position_to_cell_coordinates(local_position)
	var cell = Vector2(floor(cell_coords.x), floor(cell_coords.y))
	if cell.x < 0 or cell.x >= size.x:
		cell.x = -1
	if cell.y < 0 or cell.y >= size.y:
		cell.y = -1
	return cell
	
func local_position_to_cell_coordinates(local_position:Vector2) -> Vector2:
	return (local_position / cell_size) - offset
	
func cell_coordinates_to_local_position(cell_coords:Vector2) -> Vector2:
	return (cell_coords + offset) * cell_size
			
func _constrain_item(item):
	if item is GridItem:
		var relative_cell = item.cell - offset
		relative_cell.x = clamp(relative_cell.x, 0, size.x - 1)
		relative_cell.y = clamp(relative_cell.y, 0, size.y - 1)
		var new_cell = relative_cell + offset
		if new_cell != item.cell:
			item.cell = new_cell
			item.position = item.cell * cell_size
	else:
		for child in item.get_children():
			_constrain_item(child)

var is_dragging = [false, false, false]
	
func _input(event):
	if event is InputEventMouse:
		
		var local_position = _get_local_position(event.position)
		var cell = get_cell(local_position)
		var inside_grid = cell.x >= 0 and cell.y >= 0
		
		if event is InputEventMouseButton:
			var index = event.button_index - 1
			if index >= is_dragging.size():
					is_dragging.resize(index + 1)
			if event.pressed and inside_grid:
				is_dragging[index] = true
				emit_signal("mouse_press", event.button_index, cell)
			elif event.pressed == false:
				is_dragging[index] = false
				if inside_grid:
					emit_signal("mouse_release", event.button_index, cell)
		
		elif InputEventMouseMotion:
			if inside_grid:
				for i in is_dragging.size():
					if is_dragging[i]:
						emit_signal("mouse_drag", i + 1, cell)

func _update():
	if is_inside_tree():
		var bg = $Background
		var margin_size = Vector2(0, margin_top)
		if bg != null and bg.texture and bg.texture.get_size().length_squared() > 0:
			var texture_size = bg.texture.get_size()
			bg.rect_scale = cell_size / texture_size
			bg.rect_size = texture_size * (size - margin_size)
		else:
			bg.rect_scale = Vector2.ONE
			bg.rect_size = cell_size * size
		if bg:
			bg.rect_position = (offset + margin_size) * cell_size

func _update_children() -> void:

	for child in get_children():
		if child is Block:
			var cell = get_cell(child.position)
			add_block(child, cell)


func _ready():
	_update()
	_update_children()
	
func _process(_delta):
	if Engine.editor_hint:
		_update_children()
