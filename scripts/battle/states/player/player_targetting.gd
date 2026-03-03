extends PlayerBaseState

func enter() -> void:
	battle.update_target_highlights()

func handle_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var grid_pos = battle.grid_tiles.local_to_map(battle.get_global_mouse_position())
		if battle.grid_tiles.get_cell_tile_data(grid_pos) == null:
			return
	
		if grid_pos == battle.enemy_grid_pos:
			_try_attack(battle.playerSelectedAttack)

func _try_attack(attackType) -> void:
	if attackType == 0:
		if not battle.is_adjacent_space(battle.player_grid_pos, battle.enemy_grid_pos):
			return
		if battle.player_has_attacked:
			return
			#change to attack state	
		player_state_machine.transition_to(player_state_machine.player_attacking)
