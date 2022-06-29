extends Node2D

func _ready():
	var labels = []
	for shape in $ShapeLoader.shapes:
		labels.append(shape.resource_path)
	$RadioButtons.set_button_labels(labels)

func _on_RadioButtons_selection(_id, index, _label):
	$EditableGrid/BlockController.clear_blocks()
	$ShapeLoader.load_shape(index)
