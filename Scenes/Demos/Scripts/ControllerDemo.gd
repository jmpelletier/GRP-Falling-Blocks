# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

var kick_labels = []

func _ready():
	var labels = []
	for shape in $ShapeLoader.shapes:
		labels.append(shape.resource_path)
	$RadioButtons.set_button_labels(labels)

func _on_RadioButtons_selection(_id, index, _label):
	$EditableGrid/BlockController.clear_blocks()
	$ShapeLoader.load_shape(index)


func _on_BlockController_rotation_success(rotation_index, tries, kick_motion):
	$RotationLabel.text = "Rotation: " + str(rotation_index) + "\nTries: " + str(tries) + "\nKick: " + str(kick_motion) 
	tries -= 1
	var i = tries * 8 + rotation_index
	for j in range(kick_labels.size()):
		if i == j:
			kick_labels[j].add_color_override("font_color", Color.red)
		else:
			kick_labels[j].add_color_override("font_color", Color.black)

func _on_BlockController_rotation_fail(rotation_index):
	$RotationLabel.text = "Rotation failed: " + str(rotation_index)
	for l in kick_labels:
		l.add_color_override("font_color", Color.black)

func _on_ShapeLoader_shape_loaded(shape):
	var kicks = $EditableGrid/BlockController.kicks.duplicate()
	kick_labels = []
	for c in $Kicks/Values.get_children():
		if c is Label:
			kick_labels.append(c)
	
	var i = 0
	kicks.push_front([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])
	for k in kicks:
		for r in k:
			while i >= kick_labels.size():
				var lab = Label.new()
				lab.align = Label.ALIGN_CENTER
				lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				$Kicks/Values.add_child(lab)
				kick_labels.append(lab)
			kick_labels[i].text = str(r)
			i += 1

	while kick_labels.size() > i:
		kick_labels.back().queue_free()
		kick_labels.pop_back()
	
	
