# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.



# This script implements a metronome-like timer.
#
# This node keeps track of elapsed time in seconds, as well as quantized "units".

extends Node

 # This signal is sent every time the unit value changes.
signal on_step

# This signal is sent when the timer is set back to 0,
# either when the reset function is called manually or when
# a loop completes.
signal on_reset

# This signal is sent whenever the time is updated, either 
# in the main or physics loops.
signal on_update

# The "tempo" of the metronome, the number of beats per minute, in musical terms.
export var units_per_minute = 60

# Unit values may be multiplied by this value.
export var unit_scale = 40

# Whether the timer loops after a given number of units.
export var loop = false

# If the timer loops, how many units per loop.
export var units_per_loop = 20

# If this is true, the timer will update in the physics loop, otherwise it 
# updates in the main loop.
export var process_in_physics_loop = false

var time_seconds = 0 # The elapsed time since the last update
var time_units = 0 # The number of elapsed units
var units = 0 # Quantized number of units (integer)

var should_reset = false # Should the timer reset at the next step?

# Reset the timer immediately
func reset():
	time_seconds = 0
	time_units = 0
	units = 0
	emit_signal("on_reset")
	
# Schedule a reset when the timer reaches the next unit
func reset_at_next_step():
	should_reset = true

# Update the time (private method)
func _update(delta):
	var units_per_second = units_per_minute / 60
	
	time_seconds += delta
	time_units += delta * units_per_second
	
	var new_units = floor(time_units)
	if new_units != units:
		if should_reset or new_units == units_per_loop:
			reset()
		else:
			units = new_units
		emit_signal("on_step")
	emit_signal("on_update")

# Return the time elapsed in seconds since the last reset
func get_time():
	return time_seconds

# Return the time elapsed in units since the last reset (always in integer)
func get_units():
	return units

# Return a scaled continuous time value
func get_continuous_value():
	return time_units * unit_scale

# Return a quantized time value
func get_quantized_value():
	return units * unit_scale

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
