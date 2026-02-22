extends "res://scripts/battle/states/base_state.gd"

var target_grid_pos: Vector2i

func enter() -> void:
	battle.player_grid_pos = target_grid_pos
	var target_pos = battle.grid_tiles.map_to_local(target_grid_pos)
	var tween = battle.create_tween()
	tween.tween_property(battle.player, "position", target_pos, 0.3)
	tween.finished.connect(_on_move_finished)

func _on_move_finished() -> void:
	battle.subtract_moves(1)
	state_machine.transition_to(state_machine.player_idle)
