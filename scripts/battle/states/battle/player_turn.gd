extends BattleBaseState

func enter() -> void:
	battle.player_state_machine.turn_ended.connect(_on_turn_ended)
	battle.player_state_machine.transition_to(battle.player_state_machine.player_idle)

func exit() -> void:
	battle.player_state_machine.turn_ended.disconnect(_on_turn_ended)

func _on_turn_ended() -> void:
	battle_state_machine.transition_to(battle_state_machine.enemy_turn)
