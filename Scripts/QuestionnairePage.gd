# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends MarginContainer
class_name QuestionnairePage

signal back
signal next
signal exit
signal submit

func back():
	emit_signal("back")
	
func next():
	emit_signal("next")

func exit():
	emit_signal("exit")
	
func submit():
	emit_signal("submit")
