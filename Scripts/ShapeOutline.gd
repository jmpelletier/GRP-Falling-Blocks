# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

const OutlineBlock = preload("res://Scripts/OutlineBlock.gd")
const Block = preload("res://Scripts/Block.gd")
const BlockShape = preload("res://Scripts/BlockShape.gd")

export(Texture) var round_corner
export(Texture) var square_corner
export(Texture) var dot_corner
export(Texture) var horizontal_corner
export(Texture) var vertical_corner

export(PackedScene) var outline_block
export(PackedScene) var shape

# Corner indices
enum {TOP_RIGHT = 0, RIGHT = 1, BOTTOM_RIGHT = 2, BOTTOM = 3, BOTTOM_LEFT = 4, LEFT = 5, TOP_LEFT = 6, TOP = 7, NONE = -1}

func _ready():
	# Make sure we are inside a Block
	var block := get_parent() as Block
	if not Block:
		printerr("ShapeOutline can only be added as a child of Block.")
		return
	
	# And make sure the Block is inside a BlockShape
	var block_shape := block.get_parent() as BlockShape
	if not BlockShape:
		printerr("ShapeOutline: Disabled because Block is not in a BlockShape.")
		return
	
	# Compile a list of occupied corners
	var neighbors = [false, false, false, false, false, false, false, false]	
	
	for child in block_shape.get_children():
		var corner_position = NONE
		
		if (child is Block) and not (child == block):
			var delta = child.position - block.position
			
			if abs(delta.x) < block_shape.cell_size.x * 1.25 and abs(delta.y) < block_shape.cell_size.y * 1.25:
			
				if delta.x < block_shape.cell_size.x * -0.5:
					if delta.x >= -block_shape.cell_size.x:
						corner_position = LEFT
				elif delta.x > block_shape.cell_size.x * 0.5:
					if delta.x <= block_shape.cell_size.x:
						corner_position = RIGHT
						
				if delta.y < block_shape.cell_size.y * -0.5:
					if delta.y >= -block_shape.cell_size.y:
						if corner_position == LEFT:
							corner_position = TOP_LEFT
						elif corner_position == RIGHT:
							corner_position = TOP_RIGHT
						else:
							corner_position = TOP
				elif delta.y > block_shape.cell_size.y * 0.5:
					if delta.y <= block_shape.cell_size.y:
						if corner_position == LEFT:
							corner_position = BOTTOM_LEFT
						elif corner_position == RIGHT:
							corner_position = BOTTOM_RIGHT
						else:
							corner_position = BOTTOM
				
				print(corner_position)
				if corner_position != NONE:
					neighbors[corner_position] = true
	
	print(neighbors)
	# Corner type: none
	if neighbors[LEFT] and neighbors[TOP_LEFT] and neighbors[TOP]:
		$top_left.visible = false
		
	if neighbors[RIGHT] and neighbors[TOP_RIGHT] and neighbors[TOP]:
		$top_right.visible = false
		
	if neighbors[LEFT] and neighbors[BOTTOM_LEFT] and neighbors[BOTTOM]:
		$bottom_left.visible = false
		
	if neighbors[RIGHT] and neighbors[BOTTOM_RIGHT] and neighbors[BOTTOM]:
		$bottom_right.visible = false
		
	$top_right.texture = null
	$top_left.texture = null
	$bottom_right.texture = null
	$bottom_left.texture = null
	
	# Corner type: round
	if not neighbors[LEFT] and not neighbors[TOP_LEFT] and not neighbors[TOP]:
		$top_left.texture = round_corner

	if not neighbors[RIGHT] and not neighbors[TOP_RIGHT] and not neighbors[TOP]:
		$top_right.texture = round_corner

	if not neighbors[LEFT] and not neighbors[BOTTOM_LEFT] and not neighbors[BOTTOM]:
		$bottom_left.texture = round_corner

	if not neighbors[RIGHT] and not neighbors[BOTTOM_RIGHT] and not neighbors[BOTTOM]:
		$bottom_right.texture = round_corner

	# Corner type: dot
	if neighbors[TOP]:
		if neighbors[RIGHT] and not neighbors[TOP_RIGHT]:
			$top_right.texture = dot_corner
		elif neighbors[LEFT] and not neighbors[TOP_LEFT]:
			$top_left.texture = dot_corner
	elif neighbors[BOTTOM]:
		if neighbors[RIGHT] and not neighbors[BOTTOM_RIGHT]:
			$bottom_right.texture = dot_corner
		elif neighbors[LEFT] and not neighbors[BOTTOM_LEFT]:
			$bottom_left.texture = dot_corner
			
	# Corner type: straight horizontal
	if not neighbors[TOP] and neighbors[RIGHT]:
		$top_right.texture = horizontal_corner
		
	if not neighbors[BOTTOM] and neighbors[RIGHT]:
		$bottom_right.texture = horizontal_corner

	if not neighbors[BOTTOM] and neighbors[LEFT]:
		$bottom_left.texture = horizontal_corner

	if not neighbors[TOP] and neighbors[LEFT]:
		$top_left.texture = horizontal_corner

	# Corner type: straight vertical
	if neighbors[TOP] and not neighbors[RIGHT]:
		$top_right.texture = vertical_corner

	if neighbors[BOTTOM] and not neighbors[RIGHT]:
		$bottom_right.texture = vertical_corner

	if neighbors[BOTTOM] and not neighbors[LEFT]:
		$bottom_left.texture = vertical_corner

	if neighbors[TOP] and not neighbors[LEFT]:
		$top_left.texture = vertical_corner
		
	# Corner type: square
	if not neighbors[TOP] and not neighbors[RIGHT] and neighbors[TOP_RIGHT]:
		$top_right.texture = square_corner
		
	if not neighbors[BOTTOM] and not neighbors[RIGHT] and neighbors[BOTTOM_RIGHT]:
		$bottom_right.texture = square_corner
		
	if not neighbors[BOTTOM] and not neighbors[LEFT] and neighbors[BOTTOM_LEFT]:
		$bottom_left.texture = square_corner
		
	if not neighbors[TOP] and not neighbors[LEFT] and neighbors[TOP_LEFT]:
		$top_left.texture = square_corner
	
	