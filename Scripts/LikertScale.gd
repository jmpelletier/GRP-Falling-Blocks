# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends HBoxContainer
class_name LikertScale

signal selection(id, index, label)

export var id = "Options"
export(Array, String) var labels setget set_labels
export(PackedScene) var scale_item_scene = load("res://Scenes/Forms/LikertScaleItem.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var p = get_parent()
	while p != null and not p is Form:
		p = p.get_parent()
	if p is Form:
		var _err = p.connect("set_item_value", self, "_set_item_value")
		_err = self.connect("selection", p, "_set_selection")
		
	if Engine.editor_hint:
		set_labels(labels)
	
			
func set_labels(val:Array):
	labels = val
	for child in get_children():
		if child is LikertScaleItem:
			child.queue_free()
		
	if scale_item_scene != null:
		var group = ButtonGroup.new()
		var i = 0
		for label in labels:
			var item = scale_item_scene.instance() as LikertScaleItem
			if item == null:
				push_error("LikertScale scene is not a LikertScaleItem.")
			else:
				item.group = group
				item.value = label
				add_child(item)
				item.set_owner(self)
				item.connect("select", self, "_selected", [i])
				i += 1

func _selected(val:String, index:int):
	emit_signal("selection", id, index, val)
	
func _set_item_value(target_id:String, value):
	if target_id == id:
		if value is Dictionary and value.has("index"):
			var index = int(value["index"])
			var i = 0
			for child in get_children():
				if child is LikertScaleItem:
					child.toggle(i == index)
					i += 1
