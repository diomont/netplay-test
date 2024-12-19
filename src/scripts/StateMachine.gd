class_name StateMachine extends Node

var state_stack: Array[State] = []
var state_map = {}
var current_state_id = null
var previous_state_id = null


func process_state(delta):
	state_stack.back().update(delta)

func enter_state(state_name, params = null):
	previous_state_id = current_state_id
	current_state_id = state_name
	var state = state_map[state_name]
	state_stack.append(state)
	state.on_enter(params)
	#print("Added state ", state_name)

func replace_state(state_name, params = null):
	previous_state_id = current_state_id
	current_state_id = state_name
	var state = state_map[state_name]
	state_stack.pop_back().on_exit()
	state_stack.append(state)
	state.on_enter(params)
	#print("Replaced state with ", state_name)

func exit_state():
	state_stack.pop_back().on_exit()

func _unhandled_input(event):
	state_stack.back().handle_direct_input(event)
