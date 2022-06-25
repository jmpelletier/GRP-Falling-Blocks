# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node
class_name ClearLines

signal lines_cleared
signal update_line_count(cleared_lines)

const Grid = preload("res://Scripts/Grid.gd")

var parent_grid : Grid

var completed_rows = []

func _init():
	add_to_group("Scheduling")

# Called when the node enters the scene tree for the first time.
#func _ready():
func setup():
	parent_grid = get_parent() as Grid
	if parent_grid == null:
		push_error("ClearLines: Parent is not a Grid. Make sure to place this node inside a Grid or EditableGrid.")

func _lazy_load_grid() -> Grid:
	if parent_grid == null:
		parent_grid = get_parent() as Grid
	return parent_grid

# Clear all completed lines.
func clear_lines() -> void:
	if not _lazy_load_grid():
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
	
	Logger.log_event("cleared_lines", String(completed_rows.size()))
	emit_signal("update_line_count", completed_rows.size())
			
	completed_rows = []
	
	emit_signal("lines_cleared")
