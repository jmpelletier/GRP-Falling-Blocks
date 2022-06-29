# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends MarginContainer
class_name Form

signal set_item_value(id, value)
signal form_submit(id, data)
signal form_cancel()

export var id = "Falling blocks"
export var reload_scene_on_exit = false
export(PackedScene) var previous_scene
export(PackedScene) var next_scene
export(Array, PackedScene) var pages
export(Dictionary) var extra_data = {}

var current_index = -1
var current_page = null

var data = {}

func _ready():
	_show_page(0)
		
func _show_page(index:int):
	if index < pages.size() and index >= 0:
		if current_page != null:
			current_page.queue_free()
		
		current_page = pages[index].instance() as FormPage
		if current_page == null:
			push_error("Form page is not an instance of FormPage.")
			return
			
		add_child(current_page)
		current_page.set_owner(self)
		current_index = index
		
		current_page.connect("next", self, "_next")
		current_page.connect("back", self, "_back")
		current_page.connect("exit", self, "_exit")
		current_page.connect("submit", self, "_submit")
		
		for item_id in data.keys():
			emit_signal("set_item_value", item_id, data[item_id])

func _next():
	_show_page(current_index + 1)
	
func _back():
	_show_page(current_index - 1)
	
func _submit():
	for key in extra_data.keys():
		data[key] = extra_data[key]
	data["form_id"] = id
	emit_signal("form_submit", id, data)
	if next_scene != null:
		var _err = get_tree().change_scene_to(next_scene)
	
func _exit():
	if previous_scene != null:
		var _err = get_tree().change_scene_to(previous_scene)
	elif reload_scene_on_exit:
		var _err = get_tree().reload_current_scene()
	emit_signal("form_cancel")
		
func _set_bool(item_id:String, val:bool):
	data[item_id] = val
	
func _set_string(item_id:String, val:String):
	data[item_id] = val
	
func _set_selection(item_id:String, index:int, label:String):
	data[item_id] = {"index":index, "label":label}
	
func _set_multiple_selection(item_id:String, indices:Array, labels:Array):
	data[item_id] = {"indices": indices, "labels":labels}
