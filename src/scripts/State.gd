class_name State extends Node

var frame_count = 0
var state_id = -1


func on_enter(_params = null):
	frame_count = 0

func on_exit():
	pass

func update(_delta):
	frame_count += 1

func handle_input():
	pass

func handle_direct_input(_event):
	pass
