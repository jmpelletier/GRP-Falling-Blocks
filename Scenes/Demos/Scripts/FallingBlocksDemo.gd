# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

export var soft_drop_speedup = 8.0
export(Array, PackedScene)  var spawn_scenes

var default_ticks_per_minute = 60

var rng = RandomNumberGenerator.new()

var game_over = false

# Spawn another block controller at random
func spawn():
	if spawn_scenes.size() > 0:
		var i = rng.randi_range(0, spawn_scenes.size() - 1)
		var new_object = spawn_scenes[i].instance()
		$BlockController.grab_blocks(new_object)
		
		# First set the position above the spawn point and try to move it down.
		# If the move fails, then there is something in the way, and we set
		# the game over flag to true.
		$BlockController.set_position($SpawnPoint.position - Vector2.UP * $BlockController.cell_size.y)
		var could_move = $BlockController.move(0, 1)
		if not could_move:
			game_over = true

# Called when the node enters the scene tree for the first time.
func _ready():
	default_ticks_per_minute = $QuantizedTimer.ticks_per_minute
	$BlockController.maximum_cells_per_second.y = 0
	$BlockController.dump_target = $Grid/Obstacles
	rng.randomize()
	spawn()
	
func _process(_delta):
	if Input.is_action_pressed("move_down"):
		$QuantizedTimer.ticks_per_minute = default_ticks_per_minute * soft_drop_speedup
	else:
		$QuantizedTimer.ticks_per_minute = default_ticks_per_minute
	
func _on_QuantizedTimer_on_step():
	if $BlockController and not game_over:
		# We try to move the blocks one step down. If this fails,
		# we "dump" the blocks and spawn another controller.
		var could_move = $BlockController.move(0, 1)
		if not could_move:
			$BlockController.dump_blocks()
			spawn()
