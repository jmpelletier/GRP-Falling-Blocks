# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node2D

signal gaze_update(left, right, timestamp, epoch)

export var host_adress = "127.0.0.1"
export var host_port = 3636

var udp := PacketPeerUDP.new()
var connected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var err = udp.listen(host_port, host_adress)
	if err != OK:
		print("UDP connection error: " + err)
	else:
		print("UDP connected to " + host_adress + " port " + str(host_port))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if udp.get_available_packet_count() > 0:
		var message =  udp.get_packet().get_string_from_utf8()
		var parse_result = JSON.parse(message)
		if parse_result.error == OK:
			var left = parse_result.result["left"]
			var right = parse_result.result["right"]
			
			var left_coords = Vector2(float(left["x"]), float(left["y"]))
			var right_coords = Vector2(float(right["x"]), float(right["y"]))
			
			var time_usec = float(parse_result.result["time"])
			var time_epoch = float(parse_result.result["epoch"])
			
			emit_signal("gaze_update", left_coords, right_coords, time_usec, time_epoch)
