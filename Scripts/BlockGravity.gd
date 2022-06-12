# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

signal on_gravity_move(success)

const BlockController = preload("res://Scripts/BlockController.gd")

export var direction = Vector2.DOWN

var block_controller = null

func _ready():
	block_controller = get_parent() as BlockController

func _on_timer_step():
	if block_controller != null:
		var move_success = block_controller.move(direction)
		emit_signal("on_gravity_move", move_success)
