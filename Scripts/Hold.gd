# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends TimerDelegate
class_name Hold

signal clear_shape
signal load_next_shape
signal load_shape(shape)

var can_hold = true
var active_shape = null
var held_shape = null

func clear() -> void:
	$ShapePreview.clear()
	
func set_active(state:bool) -> void:
	if can_hold != state:
		can_hold = state
		if can_hold:
			$AnimationPlayer.play("Active")
		else:
			$AnimationPlayer.play("Inactive")
	
func hold():
	if can_hold:
		set_active(false)
		
		if active_shape != null:
			$ShapePreview.preview_shape(active_shape)
		
		emit_signal("clear_shape")
		if held_shape != null:
			emit_signal("load_shape", held_shape)
			held_shape = active_shape
		else:
			# This is a bit of a hack: We only reach this point the very first time
			# the player holds a shape. The call to "load_next_shape" would normally
			# reset can_hold to true, but we don't want that, so we change to value
			# manually here, so that signals aren't sent out.
			# "load_next_shape" will also update the active shape, so it's important
			# to update the held shape before sending the signal out.
			held_shape = active_shape
			can_hold = true
			emit_signal("load_next_shape")
			can_hold = false
			
		Logger.log_event("hold", held_shape.resource_path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
func _update(_time_sec, _delta_sec):
	if Input.is_action_just_pressed("hold"):
		hold()
		
		
func set_active_shape(shape):
	set_active(true)
	active_shape = shape
