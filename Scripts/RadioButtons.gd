# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends MarginContainer
class_name RadioButtons

signal selection(id, index, label)
signal multiple_selection(id, selection_indices, selection_labels)

enum Layout {VERTICAL, HORIZONTAL, GRID}

export var id = "Options"
export var multiple_choice = false setget set_multiple_choice
export(Array, String) var button_labels setget set_button_labels
export(Layout) var layout = Layout.VERTICAL setget set_layout
export var columns = 3 setget set_columns

var container = null
var button_group = ButtonGroup.new()

func set_multiple_choice(value:bool):
	if multiple_choice != value:
		multiple_choice = value
		
		if container != null:
			for child in container.get_children():
				if child is CheckBox:
					if multiple_choice:
						child.group = null
					else:
						child.group = button_group

func set_button_labels(value):
	button_labels = value
	_layout()
	
func set_layout(value):
	if (layout != value):
		layout = value
		_layout()
		
func set_columns(value):
	if (columns != value):
		columns = value
		_layout()

func _update_container(container_class):
	if container != null and not container is container_class:
		container.queue_free()
		container = null
	if container == null:
		for child in get_children():
			if child is container_class:
				container = child
				break
		if container == null:
			container = container_class.new()
			container.name = "Container"
			add_child(container)
		
func _layout():	
	if button_labels.empty():
		return 
		
	match layout:
		Layout.VERTICAL:
			_update_container(VBoxContainer)
		Layout.HORIZONTAL:
			_update_container(HBoxContainer)
		Layout.GRID:
			_update_container(GridContainer)
	
	container.rect_size = rect_size
	container.size_flags_horizontal = SIZE_FILL
	container.size_flags_vertical = SIZE_FILL
	
	var i = 0
	for label in button_labels:
		var btn = null
		if i < container.get_child_count():
			if container.get_child(i) is CheckBox:
				btn = container.get_child(i)
		if btn == null:
			btn = CheckBox.new()
			container.add_child(btn)

		btn.text = label
		btn.size_flags_horizontal = SIZE_EXPAND_FILL
		btn.size_flags_vertical = SIZE_EXPAND_FILL
		if not multiple_choice:
			btn.group = button_group
		
		if not btn.is_connected("toggled", self, "_on_button_toggle"):
			btn.connect("toggled", self, "_on_button_toggle", [i, label])
		
		i += 1
		
	while i < container.get_child_count():
		container.get_child(i).queue_free()
		i += 1
		
func _init():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var p = get_parent()
	while p != null and not p is Form:
		p = p.get_parent()
	if p is Form:
		var _err = p.connect("set_item_value", self, "_set_item_value")
		_err = self.connect("selection", p, "_set_selection")
		_err = self.connect("multiple_selection", p, "_set_multiple_selection")
	
	if Engine.editor_hint:
		_layout()
	
func _process(_delta):
	if Engine.editor_hint:
		if container != null:
			container.rect_size = rect_size

func _on_button_toggle(pressed, btn_index, btn_label):
	if multiple_choice:
		if container != null:
			var labels = []
			var indices = []
			var i = 0
			for child in container.get_children():
				if child is CheckBox:
					if child.pressed:
						labels.append(child.text)
						indices.append(i)
					i += 1
			emit_signal("multiple_selection", id, indices, labels)
					
	elif pressed:
		emit_signal("selection", id, btn_index, btn_label)

func _on_select(_index):
	pass
	
func _set_item_value(target_id:String, value):
	if target_id == id:
		if multiple_choice:
			if value is Dictionary and value.has("indices"):
				var i = 0
				var indices = value["indices"]
				if indices is Array:
					for child in container.get_children():
						if child is CheckBox:
							var pressed = false
							for ndx in indices:
								if ndx == i:
									pressed = true
									break
							child.pressed = pressed
							i += 1
		else:
			if value is Dictionary and value.has("index"):
				var index = int(value["index"])
				var i = 0
				for child in container.get_children():
					if child is CheckBox:
						child.pressed = i == index
						i += 1
