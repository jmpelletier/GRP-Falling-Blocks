# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Control

func _ready():
	$left_eye.visible = false
	$right_eye.visible = false

func update_display(left:Vector2, right:Vector2):
	
	var left_eye_closed = left.x < 0 or left.y < 0
	var right_eye_closed = right.x < 0 or right.y < 0
	
	$left_eye.visible = not left_eye_closed
	$right_eye.visible = not right_eye_closed
	
	$left_eye.position = rect_size * left
	$right_eye.position = rect_size * right
