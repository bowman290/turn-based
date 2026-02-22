extends Node2D

@onready var grid_tiles = $GridTiles
@onready var player = $Player
@onready var enemy = $Enemy
@onready var state_machine = $PlayerStateMachine

@export var max_player_health: int = 100
@export var max_enemy_health: int = 100
@export var melee_dmg: int = 10
@export var player_speed: int = 2

@onready var camera_2d = $Camera2D
@onready var player_health_bar = $UI/CombatUI/PlayerHealth
@onready var enemy_health_bar = $UI/CombatUI/EnemyHealth
@onready var turn_label = $UI/CombatUI/TurnLabel
@onready var moves_label = $UI/CombatUI/PlayerMovesLabel

var player_grid_pos = Vector2i(0, 0)
var enemy_grid_pos = Vector2i(-1, -1)

var player_health: int
var enemy_health: int
var player_moves: int
var player_has_attacked: bool = false
var target_tween: Tween = null

func _ready() -> void:
	player_health = max_player_health
	enemy_health = max_enemy_health
	player_moves = player_speed

	update_player_position()
	update_enemy_position()
	update_health(player_health_bar, player_health)
	update_health(enemy_health_bar, enemy_health)
	moves_label.text = "Moves Left " + str(player_moves)

	state_machine.transition_to(state_machine.player_idle)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.handle_input(event)

func end_turn() -> void:
	state_machine.transition_to(state_machine.enemy_turn)

func subtract_moves(moves: int) -> void:
	player_moves -= moves
	moves_label.text = "Moves Left " + str(player_moves)

func reset_moves() -> void:
	player_moves = player_speed
	moves_label.text = "Moves Left " + str(player_moves)

func update_health(health_node: ProgressBar, health: int) -> void:
	health_node.value = health

func update_turn_label(turn_text: String) -> void:
	turn_label.text = turn_text

func update_player_position() -> void:
	player.position = grid_tiles.map_to_local(player_grid_pos)

func update_enemy_position() -> void:
	enemy.position = grid_tiles.map_to_local(enemy_grid_pos)



func update_target_highlights() -> void:
	var enemy_targetable = is_adjacent_space(player_grid_pos, enemy_grid_pos) and !player_has_attacked and enemy_health > 0
	if enemy_targetable:
		if target_tween == null or not target_tween.is_running():
			target_tween = create_tween().set_loops()
			target_tween.tween_property(enemy, "modulate", Color(1, 0.3, 0.3), 0.5)
			target_tween.tween_property(enemy, "modulate", Color.WHITE, 0.5)
	else:
		clear_target_highlights()

func clear_target_highlights() -> void:
	if target_tween != null:
		target_tween.kill()
		target_tween = null
	enemy.modulate = Color.WHITE

func is_adjacent_space(pos1: Vector2i, pos2: Vector2i) -> bool:
	var x_diff = abs(pos1.x - pos2.x)
	var y_diff = abs(pos1.y - pos2.y)
	return y_diff == 1 and (x_diff == 0 or x_diff == 1)

func edge_distance(pos1: Vector2i, pos2: Vector2i) -> int:
	var x_diff = abs(pos1.x - pos2.x)
	var y_diff = abs(pos1.y - pos2.y)
	if x_diff <= y_diff:
		return y_diff
	elif x_diff < 2 * y_diff:
		return 2 * y_diff
	else:
		return x_diff

func _on_end_turn_btn_pressed() -> void:
	end_turn()

func _on_attack_btn_pressed() -> void:
	print('target')
