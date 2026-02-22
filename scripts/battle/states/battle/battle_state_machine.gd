extends Node

var current_state: Node

@onready var player_turn = $PlayerTurn
@onready var enemy_turn = $EnemyTurn

func transition_to(new_state: Node) -> void:
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()

func handle_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)
