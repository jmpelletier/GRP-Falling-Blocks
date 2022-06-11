# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

signal on_lockdown

const BlockController = preload("res://Scripts/BlockController.gd")

export var lockdown_time = 0.5

var block_controller

func _ready():
	block_controller = get_parent() as BlockController

func _on_block_stuck(stuck_time):
	if stuck_time >= lockdown_time:
		if block_controller != null:
			block_controller.place_blocks()
		emit_signal("on_lockdown")
