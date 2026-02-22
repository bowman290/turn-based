extends Node

var current_state: Node

@onready var player_idle = $PlayerIdle
@onready var player_moving = $PlayerMoving
@onready var player_attacking = $PlayerAttacking
@onready var enemy_turn = $EnemyTurn
@onready var player_targetting = $PlayerTargetting

func transition_to(new_state: Node) -> void:
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()

func handle_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)
