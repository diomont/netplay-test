extends Node2D

@onready var fighter_1: Fighter = $Fighter1
@onready var fighter_2: Fighter = $Fighter2

@onready var p1_inputs: Label = $CanvasLayer/P1Inputs
@onready var p2_inputs: Label = $CanvasLayer/P2Inputs

var lc_player_inputs = []
var rm_player_inputs = []
var game_frame = 0


func _ready() -> void:
	Network.player_disconnected.connect(_on_player_disconnected)
	Network.inputs_received.connect(_on_inputs_received)
	
	for i in range(Network.delay+1):
		lc_player_inputs.append([-i, 0]) # [game_frame, action_int]


func _physics_process(delta: float) -> void:
	lc_player_inputs[0] = [game_frame, InputHelper.actions_to_int()]
	Network.send_inputs.rpc(lc_player_inputs[0][1], game_frame)
	
	p1_inputs.text = inputs_to_str(lc_player_inputs)
	p2_inputs.text = inputs_to_str(rm_player_inputs)
	
	if game_frame < Network.delay:
		lc_player_inputs.pop_back()
		lc_player_inputs.push_front([-1,-1])
		game_frame += 1
		return
	
	#if game_frame > Network.received_game_frame:
	#	# local game is ahead, wait
	#	return
	
	var frame_inputs = gather_input()
	if frame_inputs[0] < 0 or frame_inputs[1] < 0:
		# no input received yet, skip update
		return
	
	lc_player_inputs.pop_back()
	lc_player_inputs.push_front([-1,-1])
	
	InputHelper.int_to_actions(frame_inputs[0], 1)
	InputHelper.int_to_actions(frame_inputs[1], 2)
	
	fighter_1.update(delta)
	fighter_2.update(delta)
	
	fighter_1.move()
	fighter_2.move()
	
	game_frame += 1


func gather_input():
	var target_frame = game_frame - Network.delay
	var inputs = [-1, -1]
	
	for pair in lc_player_inputs:
		if pair[0] == target_frame:
			inputs[0] = pair[-1]
			break
	for pair in rm_player_inputs:
		if pair[0] == target_frame:
			inputs[1] = pair[-1]
			break
	
	if Global.player_side == 2:
		inputs.reverse()
	
	return inputs


func inputs_to_str(arr: Array):
	var string = ""
	for pair in arr:
		string += "%d: %d\n" % pair
	return string


func _on_inputs_received(action_int, rm_game_frame):
	if rm_player_inputs.is_empty():
		rm_player_inputs.append([rm_game_frame, action_int])
		return
	
	var latest_rm_game_frame = rm_player_inputs[0][0]
	var oldest_rm_game_frame = rm_player_inputs[-1][0]
	var frame_diff = latest_rm_game_frame - rm_game_frame
	if frame_diff < 0:
		for i in range(abs(frame_diff)):
			rm_player_inputs.push_front([latest_rm_game_frame+i+1, -1])
		rm_player_inputs[0][1] = action_int
	else:
		if frame_diff+1 > rm_player_inputs.size():
			for i in range(frame_diff+1 - rm_player_inputs.size()):
				rm_player_inputs.push_back([oldest_rm_game_frame-i-1, -1])
		rm_player_inputs[frame_diff][1] = action_int
	
	if rm_player_inputs.size() > 9:
		# keep array small
		rm_player_inputs.resize(9)


func _on_player_disconnected(_peer_id):
	Network.remove_multiplayer_peer()
	get_tree().change_scene_to_file("res://connection_menu.tscn")
