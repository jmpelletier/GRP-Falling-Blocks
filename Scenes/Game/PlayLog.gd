# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

var frame_index = 0

var actions = []
var action_events = {}

func _ready():
	# Just to be sure (this should be set in the Scene).
	$Main/EditableGrid/BlockController.accept_user_input = false
	$Main/ShapeLoader.autoplay = false

func _events_for_key(scancode:int) -> Array:
	var ret = []
	for a in action_events.keys():
		for e in action_events[a]:
			var key_event = e as InputEventKey
			if key_event != null:
				if key_event.scancode == scancode:
					ret.append(key_event)
	return ret
	
func _process_log_event(type:String, _time:int, data:String) -> void:
	match(type):
		"seed":
			$Main/ShapeLoader.use_random_seed = true
			$Main/ShapeLoader.random_seed = int(data)
		"set_preview":
			var info = JSON.parse(data)
			if info.error == OK and info.result.has("index") and info.result.has("path"):
				$Main/ShapeLoader.set_preview_shape(int(info.result["index"]), info.result["path"])
		"set_blocks":
			var info = JSON.parse(data)
			if info.error == OK and info.result is Array:
				$Main/EditableGrid/BlockController.clear_blocks()
				for coords in info.result:
					$Main/EditableGrid/BlockController.add_block(null, Vector2(int(coords[0]), int(coords[1])))
#		"next_shape":
#			$Main/ShapeLoader.load_shape_at_path(data)
		"move":
			var info = JSON.parse(data)
			if info.error == OK and info.result.has("delta"):
				$Main/EditableGrid/BlockController.move(_get_vector2(info.result["delta"]))
		"rotate":
			var info = JSON.parse(data)
			if info.error == OK and info.result.has("origin") and info.result.has("x") and info.result.has("y"):
				var transform = Transform2D(_get_vector2(info.result["origin"]), _get_vector2(info.result["x"]), _get_vector2(info.result["y"]))
				$Main/EditableGrid/BlockController.rotate_blocks(transform)
		"hold":
			$Main/MainTimer/Hold.hold(true)
		"place":
			$Main/EditableGrid/BlockController.place_blocks(true)


func _get_vector2(dic:Dictionary) -> Vector2:
	if dic.has("x") and dic.has("y"):
		return Vector2(float(dic["x"]), float(dic["y"]))
	else:
		return Vector2.ZERO

func _on_PlaybackTimer_timer_pre_update(_time_seconds, _delta_seconds):
	if Logger.playback_log.frames.size() > frame_index:
		var frame = Logger.playback_log.frames[frame_index]
		for e in frame.events:
			_process_log_event(e[0], e[1], e[2])
#			if Logger.get_event_type(e) == "key":
#				var data = Logger.get_event_data(e)
#				var res = JSON.parse(data)
#				if res.error == OK:
#					var ev = res.result
#					var fake_event = InputEventKey.new()
#					fake_event.scancode = int(ev["scancode"])
#					fake_event.physical_scancode = int(ev["scancode"])
#					fake_event.pressed = bool(ev["pressed"])
#					fake_event.echo = bool(ev["echo"])
#
#					var key_str = OS.get_scancode_string(fake_event.scancode)
#					print("Fake event: " + key_str + ": " + str(fake_event.pressed))
#
#					Input.parse_input_event(fake_event)
#
#					$PlaybackUI/Control/KeyInput.text = key_str
#					$PlaybackUI/Control/KeyInput/AnimationPlayer.play("Show")
#					$PlaybackUI/Control/KeyInput/AnimationPlayer.seek(0, true)
		
#		if $MainTimer.enabled:
#			$PlaybackUI/Control/PlaybackLocation.value = frame_index
	else:
		_pause(true)

	frame_index += 1

func _pause(state:bool):
	if state:
		$PlaybackUI/Control/PauseButton.text = "PLAY"
	else:
		$PlaybackUI/Control/PauseButton.text = "PAUSE"
		
#	$MainTimer.enabled = not state

func _on_PauseButton_pressed():
#	_pause($MainTimer.enabled)
	pass


func _on_QuitButon_pressed():
	var _err = get_tree().change_scene("res://Scenes/Game/Start.tscn")
