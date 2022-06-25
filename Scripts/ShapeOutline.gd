# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends Node2D
class_name ShapeOutline

export(Texture) var round_corner
export(Texture) var square_corner
export(Texture) var dot_corner
export(Texture) var horizontal_corner
export(Texture) var vertical_corner

export(PackedScene) var block_outline

const NONE = -1

# Neighbor / corner indices
enum {TOP_RIGHT = 0, BOTTOM_RIGHT = 1, BOTTOM_LEFT = 2, TOP_LEFT = 3, TOP = 4, RIGHT = 5, BOTTOM = 6, LEFT = 7}

# Corner types
enum {ROUND, SQUARE, DOT, HORIZONTAL, VERTICAL}

func _get_corner_types(neighbors):

	var types = [NONE, NONE, NONE, NONE]
	
	# Corner type: round
	if not neighbors[LEFT] and not neighbors[TOP_LEFT] and not neighbors[TOP]:
		types[TOP_LEFT] = ROUND

	if not neighbors[RIGHT] and not neighbors[TOP_RIGHT] and not neighbors[TOP]:
		types[TOP_RIGHT] = ROUND

	if not neighbors[LEFT] and not neighbors[BOTTOM_LEFT] and not neighbors[BOTTOM]:
		types[BOTTOM_LEFT] = ROUND

	if not neighbors[RIGHT] and not neighbors[BOTTOM_RIGHT] and not neighbors[BOTTOM]:
		types[BOTTOM_RIGHT] = ROUND

	# Corner type: dot
	if neighbors[TOP]:
		if neighbors[RIGHT] and not neighbors[TOP_RIGHT]:
			types[TOP_RIGHT] = DOT
		if neighbors[LEFT] and not neighbors[TOP_LEFT]:
			types[TOP_LEFT] = DOT
	if neighbors[BOTTOM]:
		if neighbors[RIGHT] and not neighbors[BOTTOM_RIGHT]:
			types[BOTTOM_RIGHT] = DOT
		if neighbors[LEFT] and not neighbors[BOTTOM_LEFT]:
			types[BOTTOM_LEFT] = DOT
			
	# Corner type: straight horizontal
	if not neighbors[TOP] and neighbors[RIGHT]:
		types[TOP_RIGHT] = HORIZONTAL
		
	if not neighbors[BOTTOM] and neighbors[RIGHT]:
		types[BOTTOM_RIGHT] = HORIZONTAL

	if not neighbors[BOTTOM] and neighbors[LEFT]:
		types[BOTTOM_LEFT] = HORIZONTAL

	if not neighbors[TOP] and neighbors[LEFT]:
		types[TOP_LEFT] = HORIZONTAL

	# Corner type: straight vertical
	if neighbors[TOP] and not neighbors[RIGHT]:
		types[TOP_RIGHT] = VERTICAL

	if neighbors[BOTTOM] and not neighbors[RIGHT]:
		types[BOTTOM_RIGHT] = VERTICAL

	if neighbors[BOTTOM] and not neighbors[LEFT]:
		types[BOTTOM_LEFT] = VERTICAL

	if neighbors[TOP] and not neighbors[LEFT]:
		types[TOP_LEFT] = VERTICAL
		
	# Corner type: square
	if not neighbors[TOP] and not neighbors[RIGHT] and neighbors[TOP_RIGHT]:
		types[TOP_RIGHT] = SQUARE
		
	if not neighbors[BOTTOM] and not neighbors[RIGHT] and neighbors[BOTTOM_RIGHT]:
		types[BOTTOM_RIGHT] = SQUARE
		
	if not neighbors[BOTTOM] and not neighbors[LEFT] and neighbors[BOTTOM_LEFT]:
		types[BOTTOM_LEFT] = SQUARE
		
	if not neighbors[TOP] and not neighbors[LEFT] and neighbors[TOP_LEFT]:
		types[TOP_LEFT] = SQUARE
	
	return types
	

func _get_block_neighbors(block : Block, blocks : Array, cell_size: Vector2):

	var neighbors = [false, false, false, false, false, false, false, false]
	
	for child in blocks:
		var corner_position = NONE
		
		if not child == block:
			var delta = child.position - block.position
			
			if abs(delta.x) < cell_size.x * 1.25 and abs(delta.y) < cell_size.y * 1.25:
			
				if delta.x < cell_size.x * -0.5:
					if delta.x >= -cell_size.x:
						corner_position = LEFT
				elif delta.x > cell_size.x * 0.5:
					if delta.x <= cell_size.x:
						corner_position = RIGHT
						
				if delta.y < cell_size.y * -0.5:
					if delta.y >= -cell_size.y:
						if corner_position == LEFT:
							corner_position = TOP_LEFT
						elif corner_position == RIGHT:
							corner_position = TOP_RIGHT
						else:
							corner_position = TOP
				elif delta.y > cell_size.y * 0.5:
					if delta.y <= cell_size.y:
						if corner_position == LEFT:
							corner_position = BOTTOM_LEFT
						elif corner_position == RIGHT:
							corner_position = BOTTOM_RIGHT
						else:
							corner_position = BOTTOM
				
				if corner_position != NONE:
					neighbors[corner_position] = true
	return neighbors

func update_corners(blocks : Array, cell_size : Vector2) -> void:
	
	var textures = [round_corner, square_corner, dot_corner, horizontal_corner, vertical_corner]
	
	for block in blocks:
		# Compile a list of occupied corners
		var neighbors = _get_block_neighbors(block, blocks, cell_size)
		
		# Find the appropriate outline corners
		var corner_types = _get_corner_types(neighbors)
		
		# Instantiate block outline if needed
		var outline = block.get_outline()
		if outline == null:
			outline = block_outline.instance()
		
		var corners = [outline.get_node("top_right"), outline.get_node("bottom_right"), outline.get_node("bottom_left"), outline.get_node("top_left")]
		
		for i in range(corners.size()):
			var corner = corners[i]
			if not corner:
				push_error("ShapeOutline: Could not find corner sprites.")
				return
			if corner_types[i] == NONE:
				corner.texture = null
				corner.visible = false
			else:
				corner.texture = textures[corner_types[i]]
				corner.visible = true

		block.set_outline(outline)
		
		if not Engine.editor_hint and outline.get_parent() == null:
			add_child(outline)

func _set_corners(block_shape : BlockShape):
	
	if not block_outline:
		push_warning("Block outline scene not set.")
		return

	var blocks = []
	for target_child in block_shape.get_children():
		if target_child is Block:
			blocks.append(target_child as Block)
			
	update_corners(blocks, block_shape.cell_size)


func init_outline(shape : BlockShape):
	if shape != null:
		_set_corners(shape)

func _ready():
	if Engine.editor_hint:
		# Make sure the Block is inside a BlockShape
		var block_shape := get_parent() as BlockShape
		init_outline(block_shape)

func show():
	$AnimationPlayer.play("show")
	
func hide():
	$AnimationPlayer.play("remove")
