# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

export var agree = false
export var player_id = ""
export var start_time = ""
export var end_time = ""
export var revision = "0000000"

var game_started = false

var log_file = null

func reset() -> void:
	agree = false
	player_id = ""
	start_time = ""
	end_time = ""
	
func is_log_file_open() -> bool:
	return log_file != null and log_file.is_open()

func get_log_file_path() -> String:
	if is_log_file_open():
		return log_file.get_path_absolute()
	else:
		return ""
	
func _get_full_log_path() -> String:
	# Try to open the settings
	var config = ConfigFile.new()
	var err = config.load("res://settings.cfg")
	var log_dir = "user://logs"
	if err != OK:
		push_warning("Could not open settings file.")
	else:
		log_dir = config.get_value("log", "log_directory", "user://logs").trim_suffix("/")
		
	var fn = player_id + "_" + String(start_time) + ".csv"
	
	return log_dir + "/" + fn

func get_time() -> int:
	return OS.get_system_time_msecs()

func start_game() -> void:
	start_time = get_time()
	game_started = true
	
	# Try to get the app revision
	revision = AppVersion.version
	
	# Open a new log file
	if log_file != null:
		log_file.close()
	log_file = File.new()
	var log_file_path = _get_full_log_path()
	var err = log_file.open(log_file_path, File.WRITE)
	
	if log_file.is_open():
		log_file.store_csv_line(["player_id", "app_revision", "event_type", "time_ms", "event_data"])
	else:
		push_error("Could not open the log file: " + log_file_path + " error: " + String(err))
	
func end_game() -> void:
	end_time = get_time()
	game_started = false
	
	if log_file != null:
		log_file.close()
		log_file = null
	
func _input(event):
	if event is InputEventKey:
		log_event("key", String(event.scancode))
		
func log_event(event:String, data:String) -> void:
	if game_started and log_file != null and log_file.is_open():
		log_file.store_csv_line([player_id, revision, event, get_time(), data])
