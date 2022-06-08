# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends Control

enum Layout {VERTICAL, HORIZONTAL, GRID}

export var count = 3 setget set_count
export(Layout) var layout = Layout.VERTICAL setget set_layout
export(PackedScene) var button = preload("res://Scenes/Tools/DefaultRadioButton.tscn") setget set_button
export var columns = 3 setget set_columns

var container = null
var button_group = ButtonGroup.new()

func set_count(value):
	value = max(0, value)
	if (count != value):
		count = value
		_layout()
	
func set_layout(value):
	if (layout != value):
		layout = value
		_layout()
		
func set_button(value):
	if (button != value):
		button = value
		_layout()
		
func set_columns(value):
	if (columns != value):
		columns = value
		_layout()
		
func _layout():
	if container != null:
		container.queue_free()
	match layout:
		Layout.VERTICAL:
			container = VBoxContainer.new()
		Layout.HORIZONTAL:
			container = HBoxContainer.new()
		Layout.GRID:
			container = GridContainer.new()
			container.columns = columns
	add_child(container)
	container.rect_size = rect_size
	container.size_flags_horizontal = SIZE_FILL
	container.size_flags_vertical = SIZE_FILL
	
	for i in range(count):
		var btn = button.instance()
		btn.size_flags_horizontal = SIZE_EXPAND_FILL
		btn.size_flags_vertical = SIZE_EXPAND_FILL
		btn.group = button_group
		btn.connect("toggled", self, "_on_button_toggle", [i])
		container.add_child(btn)

# Called when the node enters the scene tree for the first time.
func _ready():
	_layout()
	
func _process(delta):
	if Engine.editor_hint:
		if container != null:
			container.rect_size = rect_size

func _on_button_toggle(pressed, btn):
	if pressed:
		_on_select(btn)

func _on_select(index):
	pass
