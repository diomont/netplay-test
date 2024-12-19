extends State


func _ready() -> void:
	state_id = Fighter.FighterState.ATTACKING


func on_enter(_params = {}):
	frame_count = 0
	owner.speed.x = 0
	owner.sprite.play("attack")


func update(delta):
	super.update(delta)
	if frame_count >= 27:
		owner.state_machine.replace_state(Fighter.FighterState.STANDING)
