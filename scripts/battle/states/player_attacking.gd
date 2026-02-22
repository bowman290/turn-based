extends "res://scripts/battle/states/base_state.gd"

var target_grid_pos: Vector2i

func enter() -> void:
	battle.enemy_health -= battle.melee_dmg
	battle.update_health(battle.enemy_health_bar, battle.enemy_health)
	battle.player_has_attacked = true
	battle.update_target_highlights()

	var hit_tween = create_tween()
	hit_tween.tween_property(battle.enemy, "scale", Vector2(1.3, 1.3), 0.1)
	hit_tween.tween_property(battle.enemy, "scale", Vector2(1, 1), 0.1)

	var shake_tween = create_tween()
	shake_tween.tween_property(battle.camera_2d, "offset", Vector2(randf_range(-3, 3), randf_range(-3, 3)), 0.1)
	shake_tween.tween_property(battle.camera_2d, "offset", Vector2.ZERO, 0.1)

	print("Enemy health is now: ", battle.enemy_health)
