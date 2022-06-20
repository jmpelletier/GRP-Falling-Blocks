# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

signal set_timer_ticks_per_second(value)
signal soft_drop_update(active)


export var soft_drop_multipler = 20.0

var gravity = 1.0

func _update(_time, _delta):
	if Input.is_action_just_pressed("soft_drop"):
		Logger.log_event("soft_drop", "start")
		emit_signal("soft_drop_update", true)
		
	if Input.is_action_just_released("soft_drop"):
		Logger.log_event("soft_drop", "end")
		emit_signal("soft_drop_update", false)
	
	if Input.is_action_pressed("soft_drop"):
			emit_signal("set_timer_ticks_per_second", gravity * soft_drop_multipler)
	else:
		emit_signal("set_timer_ticks_per_second", gravity)

func set_gravity(val:float) -> void:
	gravity = val
