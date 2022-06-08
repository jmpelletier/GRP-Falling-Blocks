# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends MarginContainer

signal clicked

export var offset = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	connect("resized", self, "_on_resize")

func _on_resize():
	layout()
	
func layout():
	var children = get_children()
	for child in children:
		if child is Node2D:
			var node = child as Node2D
			node.position = rect_size * 0.5 + offset
	
func _process(delta):
	if Engine.editor_hint:
		layout()
