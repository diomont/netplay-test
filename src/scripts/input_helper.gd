extends Node

const ACTION_MASKS = {
	"left": 1 << 0,
	"right": 1 << 1,
	"attack": 1 << 2,
}


func actions_to_int():
	var i = 0
	for action in ACTION_MASKS:
		if Input.is_action_pressed("local_" + action):
			i += ACTION_MASKS[action]
	return i


func int_to_actions(actions_int: int, player: int):
	for action in ACTION_MASKS:
		if actions_int & ACTION_MASKS[action]:
			Input.action_press("p%d_%s" % [player, action])
		else:
			Input.action_release("p%d_%s" % [player, action])
