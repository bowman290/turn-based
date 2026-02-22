extends PlayerBaseState

func enter() -> void:
	battle.update_turn_label("Player Turn")
	battle.update_target_highlights()

func handle_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		var grid_pos = battle.grid_tiles.local_to_map(battle.get_global_mouse_position())
		if battle.grid_tiles.get_cell_tile_data(grid_pos) == null:
			return
	
		if grid_pos == battle.enemy_grid_pos:
			player_state_machine.transition_to(player_state_machine.player_targetting)
		else:
			_try_move(grid_pos)

func _try_attack() -> void:
	if not battle.is_adjacent_space(battle.player_grid_pos, battle.enemy_grid_pos):
		return
	if battle.player_has_attacked:
		return
	#change to attack state	
	player_state_machine.transition_to(player_state_machine.player_attacking)
	

func _try_move(grid_pos: Vector2i) -> void:
	if battle.player_moves <= 0:
		print("Out of moves")
		return
	if not battle.is_adjacent_space(battle.player_grid_pos, grid_pos):
		print("Can only move to adjacent tiles")
		return
	player_state_machine.player_moving.target_grid_pos = grid_pos
	player_state_machine.transition_to(player_state_machine.player_moving)
