extends Node

signal lines_cleared
signal update_line_count(cleared_lines)

const Grid = preload("res://Scripts/Grid.gd")

var parent_grid : Grid

var completed_rows = []

# Called when the node enters the scene tree for the first time.
func _ready():
	parent_grid = get_parent() as Grid
	if parent_grid == null:
		push_error("ClearLines: Parent is not a Grid. Make sure to place this node inside a Grid or EditableGrid.")


# Clear all completed lines.
func clear_lines() -> void:
	if parent_grid == null:
		return
	
	completed_rows = parent_grid.get_completed_rows()
	if not completed_rows.empty():
		$AnimationPlayer.play("Clear")
	else:
		emit_signal("lines_cleared")

func hide_line_blocks(normalized_column:float) -> void:
	if not completed_rows.empty():
		for row in completed_rows:
			if row.size() > 0:
				var i = clamp(floor(normalized_column * row.size()), 0, row.size() - 1)
				row[i].hide()

func clear_line_animation_done() -> void:
	if parent_grid == null:
		return
		
	for row in completed_rows:
		for block in row:
			parent_grid.remove(block, true, Vector2.UP)
	
	emit_signal("update_line_count", completed_rows.size())
			
	completed_rows = []
	
	emit_signal("lines_cleared")
