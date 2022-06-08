tool
extends Node2D

signal moved(node)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var cell = Vector2.ZERO

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		emit_signal("moved", self)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_notify_transform(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if position != previous_position:
#		emit_signal("moved", self)
#		previous_position = position
