# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# This script implements an arrow that can be drawn from one point to another.
# You can change the thickness of the arrow by changing the weight parameter.
# If you wish to change the colour of the arrow, simply use the standard modulate
# parameter in CanvasItem's visibility settings.
# You can provide your own texture to use as an arrow. In this case, make sure to
# set NinePatchRect's patch margin parameters correctly.

tool
extends Node2D

const MIN_WEIGHT = 0.001

export var from = Vector2.ZERO setget set_from
export var to = Vector2(64, 0) setget set_to
export var weight = 1.0 setget set_weight

func set_from(value:Vector2):
	from = value
	_update()
	
func set_to(value:Vector2):
	to = value
	_update()
	
func set_weight(value:float):
	weight = max(value, MIN_WEIGHT)
	_update()
	
func _update():
	if is_inside_tree():
		var height = $NinePatch.texture.get_size().y
		$NinePatch.rect_pivot_offset = Vector2($NinePatch.patch_margin_left, height * 0.5)
		$NinePatch.rect_position = from - $NinePatch.rect_pivot_offset
		
		var delta = to - from
		$NinePatch.rect_size = Vector2($NinePatch.patch_margin_left + delta.length() / weight, height)
		$NinePatch.rect_rotation = delta.angle() * 180 / PI
		$NinePatch.rect_scale = Vector2(weight, weight)
