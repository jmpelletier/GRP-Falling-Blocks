# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

# Called when there is input from the user.
func _input(_event):
	# Check to see if the user asked to open a log file
	if Input.is_action_just_pressed("open_log"):
		$FileDialog.current_dir = ProjectSettings.globalize_path("user://logs") 
		$FileDialog.popup_centered()

# Called when a file is selected in the open log file dialog.
func _on_FileDialog_file_selected(path):
	# Validate the file:
	if Logger.is_valid_log_file(path):
		Logger.load_log(path)
		var _err = get_tree().change_scene("res://Scenes/Game/LogPlayback.tscn")
	else:
		$InvalidLogFile.popup_centered()

# Called when the form is completed
func _on_form_submit(_form_id:String, form_json:String):
	Logger.log_event("form", form_json)
	
	# Don't forget to log the start of the game.
	Logger.start_game()
	
	var _err = get_tree().change_scene("res://Scenes/Game/Main.tscn")
