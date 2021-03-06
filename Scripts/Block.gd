# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends Node2D

# The rotation offset is the displacement, in cell units,
# between the center of this block and its shape's rotation
# pivot. This is used to calculate the new position when rotating
# the shape.
# The value of this property is set automatically by the Pivot node.
# There is no need to modify it manually.
export var rotation_offset = Vector2.ZERO

var outline = null

func set_cell_size(size:Vector2) -> void:
	if $SpriteContainer/Sprite.texture != null:
		scale = 2.0 * size / $SpriteContainer/Sprite.texture.get_size()
		
func get_size() -> Vector2:
	if $SpriteContainer/Sprite.texture != null:
		return $SpriteContainer/Sprite.texture.get_size() * scale * 0.5
	else:
		return Vector2.ZERO
		
func get_bounds() -> Array:
	var bounds = [0, 0, 0, 0]
	var s = get_size()
	bounds[0] = position.x - s.x * 0.5
	bounds[1] = position.y - s.y * 0.5
	bounds[2] = position.x + s.x * 0.5
	bounds[3] = position.y + s.y * 0.5
	return bounds
	
func set_outline(block_outline : Node2D) -> void:
	if block_outline == outline:
		return
		
	if outline != null:
		remove_child(outline)
		
	outline = block_outline
	
	if Engine.editor_hint:
		add_child(outline)
		outline.position = Vector2.ZERO
		
func get_outline():
	return outline

func place_outline(offset:Vector2) -> void:
	if outline != null:
		outline.position = position + offset
		
func control():
	$AnimationPlayer.play("under_control")
	
func place():
	$AnimationPlayer.play("placed")
	
func hide():
	$AnimationPlayer.play("Hide")
