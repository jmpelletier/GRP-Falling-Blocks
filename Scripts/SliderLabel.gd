# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Label

export var decimal_digits = 2
export var custom_format_string = ""

func _format_value(value):
	if custom_format_string == "":
		var format = ("%." + str(decimal_digits) + "f") if decimal_digits > 0 else "%d"
		return format % value
	else:
		return custom_format_string % value

func _update_label(value):
	text = _format_value(value)
	
func _on_change(value):
	_update_label(value)

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()
	if parent is Slider:
		parent.connect("value_changed", self, "_on_change")
		_on_change(parent.value)
