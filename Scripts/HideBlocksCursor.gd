extends Node2D


const ClearLines = preload("res://Scripts/ClearLines.gd")

var clear_lines:ClearLines = null

export var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	clear_lines = get_parent() as ClearLines
	if clear_lines == null:
		push_error("HideBlocksCursor: Parent is not ClearLines. Make sure to place this node inside ClearLines.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if clear_lines != null:
		clear_lines.hide_line_blocks(position.x)
