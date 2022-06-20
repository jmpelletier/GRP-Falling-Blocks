tool
extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var version = ""


# Called when the node enters the scene tree for the first time.
#func _ready():
#	if Engine.editor_hint:
#		print("Allo")
#		var output = []
#		var _exit_code = OS.execute("git", ["rev-parse", "--short",  "HEAD"], true, output)
#		print(output)

func _enter_tree():
	if Engine.editor_hint:
		var output = []
		var exit_code = OS.execute("git", ["rev-parse", "--short", "HEAD"], true, output)
		if exit_code == 0 and not output.empty():
			version = output[0].strip_escapes()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
