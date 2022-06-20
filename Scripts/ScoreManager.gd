extends Node

signal points_scored(points)
signal score_changed(score)

var level = 0
var score = 0

var cleared_lines_points = [100, 300, 500, 800]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_level(val:int) -> void:
	level = val

func on_lines_cleared(count:int) -> void:
	var points = cleared_lines_points[int(clamp(count - 1, 0, cleared_lines_points.size() - 1))]
	points *= level
	
	score += points
	
	emit_signal("points_scored", points)
	emit_signal("score_changed", score)
	
