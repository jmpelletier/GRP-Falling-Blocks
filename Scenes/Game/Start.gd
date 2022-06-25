# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$id_entry.visible = false
	$StartButton.visible = false

func _on_AgreementCheckBox_toggled(_button_pressed):
	$id_entry.visible = true


func _on_IdInput_text_validated(new_text:String):
	# Validate the user id:
	if new_text.length() == 4:
		Logger.player_id = new_text
		$StartButton.visible = true


func _on_StartButton_pressed():
	Logger.start_game()
	var _err = get_tree().change_scene("res://Scenes/Game/GazeCheck.tscn")
		

func _process(_delta):
	if Input.is_action_just_pressed("open_log"):
		$FileDialog.current_dir = ProjectSettings.globalize_path("user://logs") 
		$FileDialog.popup_centered()


func _on_FileDialog_file_selected(path):
	# Validate the file:
	if Logger.is_valid_log_file(path):
		Logger.load_log(path)
		var _err = get_tree().change_scene("res://Scenes/Game/LogPlayback.tscn")
	else:
		$InvalidLogFile.popup_centered()

