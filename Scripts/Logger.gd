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

class PlaybackFrame:
	var time = 0
	var events = []
	
	func _init(t:int):
		self.time = t

class PlaybackLog:
	var subject = ""
	var app_revision = ""
	var start_time = 0
	var random_seed = 0
	var fps = 60.0
	
	var events = {}
	var frames = []
	
	func add_events_to_frames(event_type:String):
		if events.has(event_type):
			var key_i = 0
			var ev = events[event_type]
			
			for f in frames:
				for i in range(key_i, ev.size()):
					if int(ev[i][0]) > f.time:
						break
					else:
						f.events.push_back([event_type, ev[i][0], ev[i][1]])
						key_i += 1

	func sort_events_in_frames():
		for event_type in events.keys():
			add_events_to_frames(event_type)
		
		for f in frames:
			f.events.sort_custom(EventSorter, "sort_events")

	
class EventSorter:
	static func sort_events(a, b):
		if a[0] == b[0]:
			return a[2] < b[2]
		if a[0] < b[0]:
			return true
		return false
	
var playback_log = null

const HEADERS = ["player_id", "app_revision", "event_type", "time_ms", "event_data"]
enum {PLAYER_ID = 0, REVISION = 1, EVENT_TYPE = 2, EVENT_TIME = 3, EVENT_DATA = 4}

func _ready():
	pass

func reset() -> void:
	agree = false
	player_id = ""
	start_time = ""
	end_time = ""
	
func get_event_type(ev:Array) -> String:
	return ev[0]
	
func get_event_data(ev:Array) -> String:
	return ev[2]
	
func is_valid_log_file(path) -> bool:
	var f = File.new()
	var err = f.open(path, File.READ)
	if OK == err and f.is_open():
		# Read the first line
		var l = f.get_csv_line()
		if l != null and not l.empty():
			var found = false
			for h in HEADERS:
				for hh in l:
					if hh == h:
						found = true
						break
				if not found:
					return false
			return true
		f.close()
	return false
	
func load_log(path):
	if not is_valid_log_file(path):
		return
	
	var csv = File.new()
	var err = csv.open(path, File.READ)
	var index = 0
	if OK == err and csv.is_open():
		playback_log = PlaybackLog.new()
		var _header = csv.get_csv_line()
		while  not csv.eof_reached():
			var event = csv.get_csv_line()
			if event.size() == HEADERS.size():
				var event_type = str(event[EVENT_TYPE])
				var event_time = float(event[EVENT_TIME])
				playback_log.subject = event[PLAYER_ID]
				playback_log.app_revision = event[REVISION]
				if playback_log.start_time == 0:
					playback_log.start_time = event_time
				if not playback_log.events.has(event_type):
					playback_log.events[event_type] = []
					
				playback_log.events[event_type].append([event_time, event[EVENT_DATA], index])
				
				index += 1
		
		# Sort the events
		for e in playback_log.events.values ():
			e.sort_custom(EventSorter, "sort_events")
			
		# Get start time
		if playback_log.events.has("start"):
			playback_log.start_time = int(playback_log.events["start"][0][0])
			
		# Get random seed
		if playback_log.events.has("seed"):
			playback_log.random_seed = int(playback_log.events["seed"][0][1])
			
		# Get fps
		if playback_log.events.has("frame_rate"):
			playback_log.random_seed = float(playback_log.events["frame_rate"][0][1])
						
		# Extract the frames
		if playback_log.events.has("update"):
			playback_log.frames.resize(playback_log.events["update"].size())
			for i in range(playback_log.events["update"].size()):
				playback_log.frames[i] = PlaybackFrame.new(int(playback_log.events["update"][i][0]))
				
		# playback_log.add_events_to_frames("key")
		playback_log.sort_events_in_frames()
		
		csv.close()
		
func pop_playback_events(type, timestamp):
	var events = []
	if playback_log != null and playback_log.events.has(type):
		var e = playback_log.events[type]
		timestamp += playback_log.start_time
		while not e.empty():
			var t = e[0][0]
			if t > timestamp:
				break
			else:
				events.append(e.pop_front())
				
	return events
	
	
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
		log_file.store_csv_line(HEADERS)
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
		var data = JSON.print({"scancode":event.scancode,"pressed":event.pressed,"echo":event.echo})
		log_event("key", data)
		
func log_form(_form_id:String, data:Dictionary) -> void:
	if log_file != null and log_file.is_open():
		log_file.store_csv_line([player_id, revision, "form", get_time(), data])
		
func log_event(event:String, data:String) -> void:
	if game_started and log_file != null and log_file.is_open():
		log_file.store_csv_line([player_id, revision, event, get_time(), data])
		
func log_external_event(timestamp:int, event:String, data:String) -> void:
	if game_started and log_file != null and log_file.is_open():
		log_file.store_csv_line([player_id, revision, event, timestamp, data])
