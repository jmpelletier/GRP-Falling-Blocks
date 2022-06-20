# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$id_entry.visible = false
	$StartButton.visible = false

func _on_AgreementCheckBox_toggled(button_pressed):
	$id_entry.visible = true


func _on_IdInput_text_validated(new_text:String):
	# Validate the user id:
	if new_text.length() == 4:
		$StartButton.visible = true


func _on_StartButton_pressed():
	var _err = get_tree().change_scene("res://Scenes/Game/Main.tscn")
		
