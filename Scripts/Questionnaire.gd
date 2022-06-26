# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends MarginContainer
class_name Questionnaire

signal set_item_value(id, value)

export(PackedScene) var previous_scene
export(PackedScene) var next_scene
export(Array, PackedScene) var pages

var current_index = -1
var current_page = null

var data = {}

func _ready():
	_show_page(0)
		
func _show_page(index:int):
	if index < pages.size() and index >= 0:
		if current_page != null:
			current_page.queue_free()
		
		current_page = pages[index].instance() as QuestionnairePage
		if current_page == null:
			push_error("Questionnaire page is not an instance of QuestionnairePage.")
			return
			
		add_child(current_page)
		current_page.set_owner(self)
		current_index = index
		
		current_page.connect("next", self, "_next")
		current_page.connect("back", self, "_back")
		current_page.connect("exit", self, "_exit")
		current_page.connect("submit", self, "_submit")
		
		for id in data.keys():
			emit_signal("set_item_value", id, data[id])

func _next():
	_show_page(current_index + 1)
	
func _back():
	_show_page(current_index - 1)
	
func _submit():
	if next_scene != null:
		var _err = get_tree().change_scene_to(next_scene)
	
func _exit():
	if previous_scene != null:
		var _err = get_tree().change_scene_to(previous_scene)
		
func _set_bool(id:String, val:bool):
	data[id] = val
	
func _set_string(id:String, val:String):
	data[id] = val
	
func _set_selection(id:String, index:int, label:String):
	data[id] = {"index":index, "label":label}
