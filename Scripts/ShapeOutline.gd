# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

const OutlineBlock = preload("res://Scripts/OutlineBlock.gd")
const Block = preload("res://Scripts/Block.gd")
const BlockShape = preload("res://Scripts/BlockShape.gd")

export(PackedScene) var outline_block
export(PackedScene) var shape

func _ready():
	pass
