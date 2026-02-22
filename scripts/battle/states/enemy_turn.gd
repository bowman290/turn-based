extends "res://scripts/battle/states/base_state.gd"

func enter() -> void:
	battle.update_turn_label("Enemy Turn")
	battle.clear_target_highlights()
	battle.reset_moves()
	battle.player_has_attacked = false
	_run()

func _run() -> void:
	await battle.get_tree().create_timer(1.0).timeout
	# Guard against transition being called again before timer fires
	if state_machine.current_state == self:
		state_machine.transition_to(state_machine.player_idle)
