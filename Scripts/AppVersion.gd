# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

tool
extends Node

export var version = ""

func _enter_tree():
	if Engine.editor_hint:
		var output = []
		var exit_code = OS.execute("git", ["rev-parse", "--short", "HEAD"], true, output)
		if exit_code == 0 and not output.empty():
			version = output[0].strip_escapes()
