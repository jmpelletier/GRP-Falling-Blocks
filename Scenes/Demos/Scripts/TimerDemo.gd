# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D


func _on_TurboButton_toggled(button_pressed):
	if button_pressed:
		$QuantizedTimer.ticks_per_minute *= 2
	else:
		$QuantizedTimer.ticks_per_minute *= 0.5


func _on_SpeedRatioSlider_value_changed(value):
	$QuantizedTimer.speed_ratio = value


func _on_QuantizedTimer_timer_update(time_seconds, _delta_seconds):
	$"Timeline/Line marker".position.x = $QuantizedTimer.get_continuous_value()
	$"Timeline/Line marker/TimeLabel".text = "%.2f" % time_seconds


func _on_QuantizedTimer_timer_tick(ticks, _delta_ticks):
	$"Timeline/Dot marker".position.x = $QuantizedTimer.get_quantized_value()
	$"Timeline/Line marker/TicksLabel".text = str(ticks)
