# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends TimerDelegate


func _tick(ticks, delta_ticks):
	var data = {"ticks":ticks,"delta":delta_ticks}
	Logger.log_event("tick", JSON.print(data))


func _update(time_seconds, delta_seconds):
	var data = {"time":time_seconds,"delta":delta_seconds}
	Logger.log_event("update", JSON.print(data))
