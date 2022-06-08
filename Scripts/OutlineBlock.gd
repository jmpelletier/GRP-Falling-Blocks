# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
tool
extends Node2D

enum CornerShape {CORNER, HORIZONTAL_EDGE, VERTICAL_EDGE, BLANK}
enum Corner {TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT}

export(Array, CornerShape) var corner_shapes = [CornerShape.CORNER, CornerShape.CORNER, CornerShape.CORNER, CornerShape.CORNER] setget set_corner_shapes
#export var cornerShapes = [1, 2, 3]

var corners = []

func set_corner_shapes(shapes:Array):
	print("Allo")
	for i in range(min(4, shapes.size())):
		set_corner(i, shapes[i])

func _init():
	corners = [$top_left, $top_right, $bottom_left, $bottom_right]
	
	# Make sure region is enabled
	for corner in corners:
		corner.region_enabled = true		

func set_corner(corner:int, shape:int):
	match shape:
		CornerShape.HORIZONTAL_EDGE:
			corners[corner].region_rect = Rect2(20, 20, 20, 20)
		CornerShape.VERTICAL_EDGE:
			corners[corner].region_rect = Rect2(0, 0, 20, 20)
		CornerShape.CORNER:
			corners[corner].region_rect = Rect2(0, 20, 20, 20)
		CornerShape.BLANK:
			corners[corner].region_rect = Rect2(20, 0, 20, 20)
		
	corners[corner].flip_v = corner < 2
	corners[corner].flip_h = corner % 2 != 0
