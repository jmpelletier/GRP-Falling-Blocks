# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends LineEdit
class_name ValidatedInput

signal text_validated(id, new_text)
signal text_invalid(id, new_text)

export var id = "Validated"
export var allowed_characters = "0-9"
export var validation_pattern = "[0-9]{4}"

var validation_regex = RegEx.new()
var illegal_character_regex = RegEx.new()
var old_text = ""

func _ready():
	validation_regex.compile("^" + validation_pattern + "$")
	illegal_character_regex.compile("[^" + allowed_characters + "]")
	
	var p = get_parent()
	while p != null and not p is Form:
		p = p.get_parent()
	if p is Form:
		var _err = p.connect("set_item_value", self, "_set_item_value")
		_err = self.connect("text_validated", p, "_set_string")
		
	var _res = connect("text_changed", self, "_on_text_changed")
	
func _on_text_changed(new_text):
	text = illegal_character_regex.sub(new_text, "", true)
	if validation_regex.search(text):
		emit_signal("text_validated", id, text)
	else:
		emit_signal("text_invalid", id, text)

	set_cursor_position(text.length())

func _set_item_value(target_id:String, value):
	if target_id == id:
		if value is String:
			text = value
