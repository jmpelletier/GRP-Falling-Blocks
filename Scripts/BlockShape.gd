# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends "res://Scripts/Grid.gd"

export(Resource) var rotation_settings

func get_rotation_tries() -> int:
	if rotation_settings != null:
		return rotation_settings.kicks.size()
	else:
		return 0
		
func get_kick_offset(try_index:int, rotation_index:int) -> Vector2:
	if try_index >= 0 and try_index < get_rotation_tries():
		if rotation_index >= 0  and rotation_index < rotation_settings.kicks[try_index].size():
			return rotation_settings.kicks[try_index][rotation_index]
	return Vector2.ZERO
	
func get_kicks() -> Array:
	if rotation_settings != null:
		return rotation_settings.tries
	else:
		return []

func _enter_tree():
	if not Engine.editor_hint:
		printerr("You should not add BlockShape instances to a scene directly. Use utilities like ShapeLoader to add only the blocks.")

func get_outline():
	return $ShapeOutline
