# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

func _ready():
	Logger.log_event("start","")
	get_tree().call_group("Scheduling", "setup")
	
	$MainTimer.start()
