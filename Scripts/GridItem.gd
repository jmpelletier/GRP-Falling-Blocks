# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends Node2D
class_name GridItem

signal moved(node)

export var cell = Vector2.ZERO

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		emit_signal("moved", self)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_notify_transform(true)