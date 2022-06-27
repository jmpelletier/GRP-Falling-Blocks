# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends CheckBox
class_name FormCheckbox

signal check(id, state)

export var id = "Check"

func _ready():	
	var p = get_parent()
	while p != null and not p is Form:
		p = p.get_parent()
	if p is Form:
		var _err = p.connect("set_item_value", self, "_set_item_value")
		_err = self.connect("check", p, "_set_bool")
		
func _set_item_value(target_id:String, value):
	if target_id == id:
		pressed = bool(value)

func _toggled(button_pressed):
	emit_signal("check", id, button_pressed)
