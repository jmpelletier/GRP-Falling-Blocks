# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# This is a simple example of how to use QuantizedTimer delegates.

extends TimerDelegate

func _update(time, delta):
	$Time.text = "Time: " + str(time)
	$TimeDelta.text = "Time delta: " + str(delta)
	
func _tick(ticks, delta):
	$Ticks.text = "Ticks: " + str(ticks)
	$TickDelta.text = "Tick delta: " + str(delta)
