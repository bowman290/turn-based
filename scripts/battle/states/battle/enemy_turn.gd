extends BattleBaseState

func enter() -> void:
	battle.update_turn_label("Enemy Turn")
	battle.clear_target_highlights()
	battle.reset_moves()
	battle.player_has_attacked = false
	_run()

func _run() -> void:
	await battle.get_tree().create_timer(1.0).timeout
	if battle_state_machine.current_state == self:
		battle_state_machine.transition_to(battle_state_machine.player_turn)
