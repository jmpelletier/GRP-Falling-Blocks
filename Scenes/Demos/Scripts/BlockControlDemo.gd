# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

export var default_shape = 0
export(Array, PackedScene)  var spawn_scenes

var spawn_point = Vector2.ZERO

var rng = RandomNumberGenerator.new()

func spawn():
	if spawn_scenes.size() > 0:
		var i = rng.randi_range(0, spawn_scenes.size() - 1)
		var new_object = spawn_scenes[i].instance()
		$Grid/BlockController.set_position(spawn_point)
		$Grid/BlockController.grab_blocks(new_object)

# Called when the node enters the scene tree for the first time.
func _ready():
	var cells_per_second = $Grid/BlockController.maximum_cells_per_second
	$UI/HorizontalSpeedSlider.value = cells_per_second.x
	$UI/VerticalSpeedSlider.value = cells_per_second.y
	$UI/AutoshiftSlider.value = $Grid/BlockController.autoshift_delay
	
	spawn_point = $Grid/BlockController.position
	rng.randomize()
	
#	spawn()
	var new_object = spawn_scenes[default_shape].instance()
	$Grid/BlockController.grab_blocks(new_object)
	

func _on_EasingSlider_value_changed(value):
	if get_node_or_null("Grid/BlockController"):
		$Grid/BlockController.easing = value


func _on_HorizontalSpeedSlider_value_changed(value):
	if get_node_or_null("Grid/BlockController"):
		$Grid/BlockController.maximum_cells_per_second.x = value


func _on_VerticalSpeedSlider_value_changed(value):
	if get_node_or_null("Grid/BlockController"):
		$Grid/BlockController.maximum_cells_per_second.y = value


func _on_DumpBlocksButton_pressed():
	$Grid/BlockController.place_blocks()
	$UI/DumpBlocksButton.disabled = true
	$UI/SpawnButton.disabled = false


func _on_SpawnButton_pressed():
	$UI/DumpBlocksButton.disabled = false
	$UI/SpawnButton.disabled = true
	
	spawn()


func _on_AutoshiftSlider_value_changed(value):
	$Grid/BlockController.autoshift_delay = value
