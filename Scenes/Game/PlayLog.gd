# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

var frame_index = 0

var actions = []
var action_events = {}

func _ready():
	
	actions = InputMap.get_actions()
	for a in actions:
		action_events[a] = InputMap.get_action_list(a)
	
	get_tree().call_group("Scheduling", "setup")

	frame_index = 0
	
	$ShapeLoader.random_seed = Logger.playback_log.random_seed
	
	$PlaybackUI/Control/PlaybackLocation.max_value = Logger.playback_log.frames.size() - 1
	
	$MainTimer.start()

func _events_for_key(scancode:int) -> Array:
	var ret = []
	for a in action_events.keys():
		for e in action_events[a]:
			var key_event = e as InputEventKey
			if key_event != null:
				if key_event.scancode == scancode:
					ret.append(key_event)
	return ret

func _on_MainTimer_timer_pre_update(_time_seconds, _delta_seconds):
	if Logger.playback_log.frames.size() > frame_index:
		var frame = Logger.playback_log.frames[frame_index]
		for e in frame.events:
			if Logger.get_event_type(e) == "key":
				var data = Logger.get_event_data(e)
				var res = JSON.parse(data)
				if res.error == OK:
					var ev = res.result
					var fake_event = InputEventKey.new()
					fake_event.scancode = int(ev["scancode"])
					fake_event.physical_scancode = int(ev["scancode"])
					fake_event.pressed = bool(ev["pressed"])
					fake_event.echo = bool(ev["echo"])
					
					var key_str = OS.get_scancode_string(fake_event.scancode)
					print("Fake event: " + key_str + ": " + str(fake_event.pressed))
					
					Input.parse_input_event(fake_event)

					$PlaybackUI/Control/KeyInput.text = key_str
					$PlaybackUI/Control/KeyInput/AnimationPlayer.play("Show")
					$PlaybackUI/Control/KeyInput/AnimationPlayer.seek(0, true)
					
			if Logger.get_event_type(e) == "gaze":
				var data = Logger.get_event_data(e)
				var res = JSON.parse(data)
				if res.error == OK:
					var ev = res.result
					var left = Vector2(ev["left"]["x"], ev["left"]["y"])
					var right = Vector2(ev["right"]["x"], ev["right"]["y"])
					
					$GazeDisplay.update_display(left, right)
		
		if $MainTimer.enabled:
			$PlaybackUI/Control/PlaybackLocation.value = frame_index
	else:
		_pause(true)

	frame_index += 1

func _pause(state:bool):
	if state:
		$PlaybackUI/Control/PauseButton.text = "PLAY"
	else:
		$PlaybackUI/Control/PauseButton.text = "PAUSE"
		
	$MainTimer.enabled = not state

func _on_PauseButton_pressed():
	_pause($MainTimer.enabled)


func _on_QuitButon_pressed():
	get_tree().change_scene("res://Scenes/Game/Start.tscn")
