extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const TARGET_GAZE_DURATION = 5

var gaze_position = Vector2.ZERO

var target_rect:Rect2

var target_gaze_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	target_rect = $StartLabel.get_rect()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target_rect.has_point(gaze_position * rect_size):
		target_gaze_time += delta
		if target_gaze_time >= TARGET_GAZE_DURATION:
			var _err = get_tree().change_scene("res://Scenes/Game/Main.tscn")

	else:
		target_gaze_time = 0
		
	$StartLabel/ProgressBar.value = target_gaze_time


func _on_GazeManager_gaze_update(left:Vector2, right:Vector2, _timestamp:float, epoch:float):
	var time = OS.get_system_time_msecs()
	
	$GazeEpochLabel.text = str(int(epoch))
	$CPUTimeLabel.text = str(int(time))
	
	var latency_ms = time - epoch
	
	$LatencyLabel.text = str(int(latency_ms))
	
	var left_eye_closed = left.x < 0 or left.y < 0
	var right_eye_closed = right.x < 0 or right.y < 0
	
	if not left_eye_closed and not right_eye_closed:
		gaze_position = (left + right) * 0.5
	elif not left_eye_closed:
		gaze_position = left
	elif not right_eye_closed:
		gaze_position = right
	
	
	$left_eye.visible = not left_eye_closed
	$right_eye.visible = not right_eye_closed
	
	$left_eye.position = rect_size * left
	$right_eye.position = rect_size * right
	
	$LeftEyePositionLabel.text = str(left)
	$RightEyePositionLabel.text = str(right)


func _on_BackButton_pressed():
	var _err = get_tree().change_scene("res://Scenes/Game/Start.tscn")
