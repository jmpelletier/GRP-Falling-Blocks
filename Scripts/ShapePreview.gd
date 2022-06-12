extends Node2D

const Block = preload("res://Scripts/Block.gd")
const Grid = preload("res://Scripts/Grid.gd")

export var display_offset = Vector2(3, 3)

func preview_shape(shape_scene:PackedScene) -> void:
	
	# Clear the existing shape
	$Grid.clear_blocks()
	
	# Load the new shape
	var shape = shape_scene.instance() as Grid
	if shape == null:
		push_error("ShapePreview: Packed scene is not a Grid.")
		return 
	
	# Add the blocks to the preview grid
	for child in shape.get_children():
		if child is Block:
			var from_cell = shape.get_cell(child.position) + shape.offset
			var to_cell = from_cell + display_offset
			shape.remove_child(child)
			$Grid.add_block(child, to_cell)
