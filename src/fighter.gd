class_name Fighter extends Node2D

enum FighterState {STANDING, WALKINGFORWARD, WALKINGBACKWARD, ATTACKING, BLOCKING, HITSTUN}

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine

@export var player: int = 1
@export var direction: int = 1
var speed := Vector2i()


func _ready() -> void:
	state_machine.state_map = {
		FighterState.STANDING: $StateMachine/Standing,
		FighterState.WALKINGFORWARD: $StateMachine/WalkingForward,
		FighterState.WALKINGBACKWARD: $StateMachine/WalkingBackward,
		FighterState.ATTACKING: $StateMachine/Attacking,
		FighterState.BLOCKING: $StateMachine/Blocking,
		FighterState.HITSTUN: $StateMachine/Hitstun,
	}
	state_machine.enter_state(FighterState.STANDING)
	position.y = Global.STAGE_FLOOR
	if direction < 0: sprite.flip_h = true


func move():
	position.x += speed.x * direction
	position.y += speed.y
	position = position.clamp(
		Vector2(Global.STAGE_LIMITS[0], 0),
		Vector2(Global.STAGE_LIMITS[1], Global.STAGE_FLOOR)
	)


func update(delta):
	state_machine.process_state(delta)
