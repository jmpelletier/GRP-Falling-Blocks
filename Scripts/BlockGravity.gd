# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

signal on_stuck(stuck_time)

const BlockController = preload("res://Scripts/BlockController.gd")

export var direction = Vector2.DOWN

var block_controller = null

var time = 0.0
var is_stuck = false
var stuck_start_time = 0

func _process(delta):
	time += delta
	if is_stuck:
		emit_signal("on_stuck", time - stuck_start_time)

func _ready():
	block_controller = get_parent() as BlockController

func _on_timer_step():
	if block_controller != null:
		var move_success = block_controller.move(direction)
		if not move_success:
			if not is_stuck:
				_reset_stuck_time()
			is_stuck = true
		else:
			is_stuck = false

func _reset_stuck_time():
	stuck_start_time = time

func _reset_stuck_state():
	is_stuck = false
	_reset_stuck_time()
