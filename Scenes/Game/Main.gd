# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

enum Mode {PLAY, PLAYBACK}
export(Mode) var mode = Mode.PLAY

func _ready():
	get_tree().call_group("Scheduling", "setup")

	if mode == Mode.PLAY:
		Logger.log_event("start","")
				
		$MainTimer.start()
