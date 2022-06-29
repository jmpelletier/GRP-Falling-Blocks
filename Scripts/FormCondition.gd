# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

export(NodePath) var target = null
export var target_visible_on_load = false

func _ready():
	var checkbox = get_parent() as CheckBox
	if checkbox != null:
		checkbox.connect("toggled", self, "_on_toggle")
		
	var radio_buttons = get_parent() as RadioButtons
	if radio_buttons != null:
		radio_buttons.connect("selection", self, "_on_selection")
		
	var likert_scale = get_parent() as LikertScale
	if likert_scale != null:
		likert_scale.connect("selection", self, "_on_selection")
		
	var validated_input = get_parent() as ValidatedInput
	if validated_input != null:
		validated_input.connect("text_validated", self, "_on_input_validated")
		validated_input.connect("text_invalid", self, "_on_invalid_input")
		
	_show_target(target_visible_on_load)
		
func _show_target(visible:bool) -> void:
	if target != null:
		var control = get_node(target) as Control
		if control != null:
			if visible and not control.visible:
				control.grab_focus()
			control.visible = visible
			

func _on_toggle(pressed:bool) -> void:
	_show_target(pressed)

func _on_selection(_id:String, _index:int, _label:String) -> void:
	_show_target(true)
	
func _on_input_validated(_id:String, _input:String) -> void:
	_show_target(true)
	
func _on_invalid_input(_id:String, _input:String) -> void:
	_show_target(false)
