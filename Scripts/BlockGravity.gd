# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

signal ground_check(can_move)


const BlockController = preload("res://Scripts/BlockController.gd")

export var direction = Vector2.DOWN
export var lines_per_second = 1
export var soft_drop_multiplier = 20.0

var block_controller = null

var lines_to_move = 0
var time = 0

func _ready():
	for n in get_parent().get_children():
		if n is BlockController:
			block_controller = n
			break

func _update(_time_secs, _delta):
	if block_controller != null:
		emit_signal("ground_check", block_controller.can_move(direction))

func _tick(_ticks, delta_ticks):
	if block_controller != null:
		var _move_success = block_controller.move(direction * delta_ticks)
