# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

export(PackedScene) var restartScene

func _init():
	add_to_group("Scheduling")

func setup():
	visible = false

# Called when the node enters the scene tree for the first time.
#func _ready():
#	visible = false

func _on_ShapeLoader_cannot_place():
	visible = true
	
	if Logger.is_log_file_open():
		$LogLocation.text = "Will save log: " + Logger.get_log_file_path()
	else:
		$LogLocation.text = "Cannot save log"

func restart():	
	Logger.end_game()
	if restartScene != null:
		var _err = get_tree().change_scene_to(restartScene)
	else:
		var _err = get_tree().reload_current_scene()
