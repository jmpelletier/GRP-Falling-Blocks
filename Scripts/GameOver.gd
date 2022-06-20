extends Node2D


export(PackedScene) var restartScene

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

func _on_ShapeLoader_cannot_place():
	visible = true

func restart():
	if restartScene != null:
		var _err = get_tree().change_scene_to(restartScene)
	else:
		var _err = get_tree().reload_current_scene()
