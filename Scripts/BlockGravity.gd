# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

signal on_gravity(success)


const BlockController = preload("res://Scripts/BlockController.gd")

export var direction = Vector2.DOWN

var block_controller = null

func _ready():
	block_controller = get_parent() as BlockController
	
func _on_timer_update(_time_secs, _time_ticks):
	emit_signal("on_gravity", block_controller.can_move(direction))		

func _on_timer_step(_time_secs, _time_ticks):
	if block_controller != null:
		var _move_success = block_controller.move(direction)
