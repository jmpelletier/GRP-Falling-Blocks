# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends LineEdit

signal text_validated(new_text)

var regex = RegEx.new()
var old_text = ""

func _ready():
	regex.compile("^[0-9]*$")
	connect("text_changed", self, "_on_text_changed")
	

func _on_text_changed(new_text):
	if regex.search(new_text):
		text = new_text   
		old_text = text
		emit_signal("text_validated", text)
	else:
		text = old_text
	set_cursor_position(text.length())
