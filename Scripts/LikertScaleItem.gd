# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends VBoxContainer
class_name LikertScaleItem

signal select(val)

export(String) var value setget set_value
export(ButtonGroup) var group setget set_group

func _ready():
	var _err = $CenterContainer/CheckBox.connect("toggled", self, "toggle")

func set_value(val:String):
	value = val
	$Label.text = val
	
func set_group(val:ButtonGroup):
	$CenterContainer/CheckBox.group = val

func toggle(val:bool):
	if val:
		$CenterContainer/CheckBox.pressed = val
		emit_signal("select", value)
