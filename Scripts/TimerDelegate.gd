# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# When logging events, and playing back logs, it's a good idea to have some control
# of where timing events come from.
#
# This class should be used as the base class of any node that affects gameplay,
# or needs to log events in real-time. These nodes are then placed as childs of 
# a timer node that will signal its children when necessary.

tool
extends Node
class_name TimerDelegate

# Display a warning in the editor if this node is not a child of a QuantizedTimer.
func _get_configuration_warning() -> String:
	if get_parent() is QuantizedTimer:
		return ""
	else:
		return "This node must be the child of a QuantizedTimer to function properly."
		
func _enter_tree():
	var timer = get_parent() as QuantizedTimer
	if timer != null:
		timer.connect("timer_reset", self, "_reset")
		timer.connect("timer_started", self, "_start")
		timer.connect("timer_stopped", self, "_stop")
		timer.connect("timer_pre_update", self, "_pre_update")
		timer.connect("timer_update", self, "_update")
		timer.connect("timer_tick", self, "_tick")
	
func _exit_tree():
	var timer = get_parent() as QuantizedTimer
	if timer != null:
		timer.disconnect("timer_reset", self, "_reset")
		timer.disconnect("timer_started", self, "_start")
		timer.disconnect("timer_stopped", self, "_stop")
		timer.disconnect("timer_pre_update", self, "_pre_update")
		timer.disconnect("timer_update", self, "_update")
		timer.disconnect("timer_tick", self, "_tick")

# This gets called when the timer is reset.
func _reset() -> void:
	pass
	
# The timer was started.
func _start() -> void:
	pass
	
# The timer was stopped.
func _stop() -> void:
	pass

# This gets called before just _update.
func _pre_update(_time_sec:float, _delta_sec:float) -> void:
	pass

# This gets called on every frame. Note that 'frame' may not necessarily correspond
# to Godot's standard _process callback. 
func _update(_time_sec:float, _delta_sec:float) -> void:
	pass

# This gets called on every timer 'tick'.
func _tick(_ticks:int, _delta_ticks:int) -> void:
	pass
