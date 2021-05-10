# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Use this script to keep track of "kicking" behaviour. When a rotation is 
# attempted and fails because of a collision, it is attempted again after 
# translation. This script allows you to define the translation offsets for the 
# succesive kicking "tries".
# There should be no need to edit this script directly. Instead, simply set the 
# forward translation offsets in the inspector. If the mirror property is true,
# the offsets will be mirrored for the inverse rotations, which is the usual
# behaviour.

tool
extends Node2D

export(int) var tries = 4
export var mirror = true

var offsets = [[Vector2(1,0),Vector2(1,1),Vector2(0,-2),Vector2(1,-2)],
	[Vector2(1,0),Vector2(1,1),Vector2(0,-2),Vector2(1,-2)],
	[Vector2(-1,0),Vector2(-1,1),Vector2(0,-2),Vector2(-1,-2)],
	[Vector2(-1,0),Vector2(-1,1),Vector2(0,-2),Vector2(-1,-2)],
	[Vector2(-1,0),Vector2(-1,-1),Vector2(0,2),Vector2(-1,2)],
	[Vector2(-1,0),Vector2(-1,-1),Vector2(0,2),Vector2(-1,2)],
	[Vector2(1,0),Vector2(1,-1),Vector2(0,2),Vector2(1,2)],
	[Vector2(1,0),Vector2(1,-1),Vector2(0,2),Vector2(1,2)]]

var offset_labels = ["forward rotation offsets/0 to ccw",
	"forward rotation offsets/180 to ccw",
	"forward rotation offsets/0 to cw",
	"forward rotation offsets/180 to cw",
	"reverse rotation offsets/ccw to 0",
	"reverse rotation offsets/ccw to 180",
	"reverse rotation offsets/cw to 0",
	"reverse rotation offsets/cw to 180"]
	
func _get_settings_index(from_angle, to_angle):
	if from_angle == 0 and to_angle == 90:
		return 0
	elif from_angle == 180 and to_angle == 90:
		return 1
	elif from_angle == 0 and to_angle == -90:
		return 2
	elif from_angle == 180 and to_angle == -90:
		return 3
	elif from_angle == 90 and to_angle == 0:
		return 4
	elif from_angle == 90 and to_angle == 180:
		return 5
	elif from_angle == -90 and to_angle == 0:
		return 6
	elif from_angle == -90 and to_angle == 180:
		return 7
	return -1

func get_settings(from_angle, to_angle):
	var index = _get_settings_index(from_angle, to_angle)
	if index > -1:
		return offsets[index]
	else:
		return null


func _mirror_offsets(a:Array, b:Array):
	b.resize(a.size())
	for i in range(a.size()):
		b[i] = a[i] * -1
		
func _resize_offsets(a:Array, size:int):
	while a.size() > size:
		a.pop_back()
		
	while a.size() < size:
		a.push_back(Vector2.ZERO)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Engine.editor_hint:
		if tries < 0:
			tries = 0
		
		for offset in offsets:
			_resize_offsets(offset, tries)
		
		if mirror:
			for i in range(0, int(offsets.size() / 2)):
				_mirror_offsets(offsets[i], offsets[i + int(offsets.size() / 2)])

func _get(property):
	var i = offset_labels.find(property)
	if i > -1:
		return offsets[i]


func _set(property, value):
	var i = offset_labels.find(property)
	if i > -1:
		offsets[i] = value
		return true
	else:
		return false

func _get_property_list():
	var list = []
	for label in offset_labels:
		list.push_back({
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT,
			"name": label,
			"type": TYPE_ARRAY
		})
	return list
