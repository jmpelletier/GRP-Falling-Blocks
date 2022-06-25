# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

var clear_lines:ClearLines = null

export var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	clear_lines = get_parent() as ClearLines
	if clear_lines == null:
		push_error("HideBlocksCursor: Parent is not ClearLines. Make sure to place this node inside ClearLines.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if clear_lines != null:
		clear_lines.hide_line_blocks(position.x)
