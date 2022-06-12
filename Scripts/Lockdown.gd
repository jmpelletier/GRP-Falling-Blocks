# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

signal on_lockdown
signal on_lockdown_countdown(time_left)

enum LockdownMode {INFINITE, MOVE, STEP}

export var lockdown_time = 0.5
export(LockdownMode) var lockdown_mode = LockdownMode.INFINITE
export var max_lockdown_moves = 15

var lockdown_start_time = 0
var lockdown_moves = 0
var time = 0
var is_lockdown = false

func get_lockdown_time() -> float:
	if is_lockdown:
		return time - lockdown_start_time
	else:
		return 0.0
		
func get_lockdown_time_left() -> float:
	return lockdown_time - get_lockdown_time()

func reset_lockdown_time():
	lockdown_start_time = time
		
func _check_lockdown():
	if is_lockdown and time - lockdown_start_time >= lockdown_time:
		emit_signal("on_lockdown")
		is_lockdown = false
		
func update(time_seconds, _time_ticks):
	time = time_seconds

func _on_user_action(line_change:int) -> void:
	if is_lockdown:
		match lockdown_mode:
			LockdownMode.INFINITE:
				lockdown_start_time = time
			LockdownMode.MOVE:
				if lockdown_moves < max_lockdown_moves:
					lockdown_start_time = time
					lockdown_moves += 1
			LockdownMode.STEP:
				if line_change > 0:
					lockdown_start_time = time

func _on_gravity(can_move:bool):
	if can_move:
		is_lockdown = false
	else:
		if not is_lockdown:
			lockdown_start_time = time
			lockdown_moves = 0
			is_lockdown = true
		emit_signal("on_lockdown_countdown", get_lockdown_time_left())
		_check_lockdown()
