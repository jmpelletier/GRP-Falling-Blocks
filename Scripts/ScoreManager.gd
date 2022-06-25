# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

signal points_scored(points)
signal score_changed(score)

var level = 0
var score = 0

var in_soft_drop = false

var cleared_lines_points = [100, 300, 500, 800]

func set_level(val:int) -> void:
	level = val
	
func _update_score(points:int) -> void:
	score += points
	
	Logger.log_event("points_scored", String(points))
	Logger.log_event("score_total", String(score))
	emit_signal("points_scored", points)
	emit_signal("score_changed", score)

func on_lines_cleared(count:int) -> void:
	var points = cleared_lines_points[int(clamp(count - 1, 0, cleared_lines_points.size() - 1))]
	points *= level
	_update_score(points)
	
func on_soft_drop_update(state:bool) -> void:
	in_soft_drop = state
	
func on_hard_drop(motion:Vector2) -> void:
	var points = motion.length() * 2
	_update_score(points)
	
func on_gravity_move(motion:Vector2) -> void:
	if in_soft_drop:
		var points = motion.length()
		_update_score(points)
