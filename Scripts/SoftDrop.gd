# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

signal set_timer_ticks_per_second(value)


export var soft_drop_multipler = 20.0

var gravity = 1.0

func _update(_time, _delta):
	if Input.is_action_pressed("soft_drop"):
			emit_signal("set_timer_ticks_per_second", gravity * soft_drop_multipler)
	else:
		emit_signal("set_timer_ticks_per_second", gravity)

func set_gravity(val:float) -> void:
	gravity = val
