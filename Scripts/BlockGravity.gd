# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends TimerDelegate
class_name BlockGravity

signal ground_check(can_move)
signal gravity_move(motion)

export(NodePath) var block_controller_path = null
export var direction = Vector2.DOWN
export var lines_per_second = 1
export var soft_drop_multiplier = 20.0

var block_controller = null

var lines_to_move = 0
var time = 0

func _get_configuration_warning():
	var ret = ._get_configuration_warning()
	if ret == "":
		if block_controller_path == null:
			ret = "Block controller path is not setup. This node will not function properly."
	return ret

func _init():
	add_to_group("Scheduling")
	
func _lazy_load_block_controller():
	if block_controller == null and block_controller_path != null:
		block_controller = get_node(block_controller_path)

func _update(_time_secs, _delta):
	_lazy_load_block_controller()
	if block_controller != null:
		emit_signal("ground_check", block_controller.can_move(direction))

func _tick(_ticks, delta_ticks):
	_lazy_load_block_controller()
	if block_controller != null:
		var motion = block_controller.move(direction * delta_ticks)
		Logger.log_event("gravity", JSON.print({"x":motion.x,"y":motion.y}))
		move(motion)
			
func move(motion):
	if motion.length_squared() > 0:
		emit_signal("gravity_move", motion)
