# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.



# This script implements a metronome-like timer.
#
# This node keeps track of elapsed time in seconds, as well as quantized "ticks".
extends Node

 # This signal is sent every time the unit value changes.
signal timer_tick(ticks, delta_ticks)

# This signal is sent when the timer is set back to 0,
# either when the reset function is called manually or when
# a loop completes.
signal timer_reset

# This signal is sent whenever the time is updated, either 
# in the main or physics loops.
signal timer_update(time_seconds, delta_seconds)

# Whether the timer is ticking
export var enabled = true

# The "tempo" of the metronome, the number of beats per minute, in musical terms.
export var ticks_per_minute = 60.0

# Unit values may be multiplied by this value.
export var unit_scale = 40.0

# Whether the timer loops after a given number of ticks.
export var loop = false

# If the timer loops, how many ticks per loop.
export var ticks_per_loop = 20.0

# If this is true, the timer will update in the physics loop, otherwise it 
# updates in the main loop.
export var process_in_physics_loop = false

var time_seconds = 0 # The elapsed time since the last update
var time_ticks = 0 # The number of elapsed ticks
var ticks = 0 # Quantized number of ticks (integer)

var should_reset = false # Should the timer reset at the next step?

# Reset the timer immediately
func reset():
	time_seconds = 0
	time_ticks = 0
	ticks = 0
	emit_signal("timer_reset")
	
# Schedule a reset when the timer reaches the next unit
func reset_at_next_step():
	should_reset = true
	
func start():
	enabled = true
	
func stop():
	enabled = false
	
func set_ticks_per_second(val:float) -> void:
	ticks_per_minute = val * 60.0

# Update the time (private method)
func _update(delta):
	var ticks_per_second = ticks_per_minute / 60.0
	
	time_seconds += delta
	time_ticks += delta * ticks_per_second
	
	var new_ticks = floor(time_ticks)
	if new_ticks != ticks:
		var delta_ticks = new_ticks - ticks
		if should_reset or (loop and new_ticks == ticks_per_loop):
			reset()
		else:
			ticks = new_ticks
		if enabled:
			emit_signal("timer_tick", ticks, delta_ticks)
	if enabled:
		emit_signal("timer_update", time_seconds, delta)

# Return the time elapsed in seconds since the last reset
func get_time():
	return time_seconds

# Return the time elapsed in ticks since the last reset (always in integer)
func get_ticks():
	return ticks

# Return a scaled continuous time value
func get_continuous_value():
	return time_ticks * unit_scale

# Return a quantized time value
func get_quantized_value():
	return ticks * unit_scale

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not process_in_physics_loop:
		_update(delta)
	
func _physics_process(delta):
	if process_in_physics_loop:
		_update(delta)
