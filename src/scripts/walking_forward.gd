extends State

@export var walk_speed: int = 5


func _ready() -> void:
	state_id = Fighter.FighterState.WALKINGFORWARD


func on_enter(_params = {}):
	frame_count = 0
	owner.sprite.play("walk_f")


func update(delta):
	super.update(delta)
	owner.speed.x = walk_speed
	
	var dir_input = Input.get_axis("p%d_left" % owner.player, "p%d_right" % owner.player)
	
	var back = (dir_input < 0 and owner.direction > 0) \
		or (dir_input > 0 and owner.direction < 0)
	var front = (dir_input < 0 and owner.direction < 0) \
		or (dir_input > 0 and owner.direction > 0)
	
	if Input.is_action_just_pressed("p%d_attack" % owner.player):
		owner.state_machine.replace_state(Fighter.FighterState.ATTACKING)
	elif back:
		owner.state_machine.replace_state(Fighter.FighterState.WALKINGBACKWARD)
	elif not front:
		owner.state_machine.replace_state(Fighter.FighterState.STANDING)
