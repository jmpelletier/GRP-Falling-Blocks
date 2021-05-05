# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

func _on_QuantizedTimer_update():
	$"Timeline/Line marker".position.x = $QuantizedTimer.get_continuous_value()
	$"Timeline/Line marker/TimeLabel".text = "%.2f" % $QuantizedTimer.get_time()


func _on_QuantizedTimer_step():
	$"Timeline/Dot marker".position.x = $QuantizedTimer.get_quantized_value()
	$"Timeline/Line marker/TicksLabel".text = str($QuantizedTimer.get_ticks())

func _on_TurboButton_toggled(button_pressed):
	if button_pressed:
		$QuantizedTimer.ticks_per_minute *= 2
	else:
		$QuantizedTimer.ticks_per_minute *= 0.5
