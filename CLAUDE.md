# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a turn-based tactical game built with Godot 4.5 using GDScript. The game features grid-based combat with player and enemy characters on an isometric tile map.

## Running the Project

This project requires Godot 4.5 to run. Open the project in the Godot editor and press F5 to run, or use the Godot command line:

```bash
godot --path . # Opens the project in the editor
godot --path . --headless # Runs without editor (for CI/testing)
```

The main scene is `scenes/levels/battle.tscn` which is set as the main scene in `project.godot`.

## Project Structure

```
scripts/
  battle/
    battle.gd                         # Main battle scene controller (data + shared utilities)
    states/
      battle/
        battle_base_state.gd          # Base class for battle states; exports battle + battle_state_machine
        battle_state_machine.gd       # Manages turn flow (PlayerTurn / EnemyTurn)
        player_turn.gd                # Active during player's turn; connects to turn_ended signal
        enemy_turn.gd                 # Enemy acting; waits 1s then returns to PlayerTurn
      player/
        player_base_state.gd          # Base class for player states; exports battle + player_state_machine
        player_state_machine.gd       # Manages player actions; emits turn_ended signal
        player_idle.gd                # Waiting for input; routes clicks to move, attack, or target
        player_moving.gd              # Tween animation playing; ignores input until complete
        player_attacking.gd           # Handles melee attack flow
        player_targetting.gd          # Player is selecting a target

scenes/
  levels/battle.tscn                  # Main battle scene with tilemap, UI, and combat setup
  players/
    player.tscn                       # Player character scene
    enemy.tscn                        # Enemy character scene

assets/
  battle/                             # Tile sprites for isometric grid
  sprite_sheets/                      # Character sprites
```

## Core Architecture

### Battle System (scripts/battle/battle.gd)

`battle.gd` is the data owner and utility layer. It does not contain turn or input logic — that lives in the state machines. It manages:

1. **Shared State**: Player/enemy grid positions, health, moves remaining, attack flag
2. **Grid Helpers**: Conversion between grid coordinates (Vector2i) and world positions
3. **UI Updates**: Health bars, turn label, moves label, target highlights
4. **Combat Utilities**: `melee_attack()`, `is_adjacent_space()`, `edge_distance()`
5. **Input Entry Point**: `_unhandled_input` forwards raw input to `player_state_machine.handle_input(event)`
6. **Turn End**: `end_turn()` emits `player_state_machine.turn_ended` signal

### Two State Machines

The architecture uses two separate state machines with distinct responsibilities:

**BattleStateMachine** — owns the turn flow
- Lives at `$BattleStateMachine` in the scene
- States: `PlayerTurn`, `EnemyTurn`
- `battle._ready()` starts it in `PlayerTurn`

**PlayerStateMachine** — owns what the player can do on their turn
- Lives at `$PlayerStateMachine` in the scene
- States: `PlayerIdle`, `PlayerMoving`, `PlayerAttacking`, `PlayerTargetting`
- Activated by `PlayerTurn.enter()`
- Emits `turn_ended` signal when the player's turn should end

### Turn End Signal Flow

The two machines communicate via a signal rather than direct calls, keeping them decoupled:

```
Player presses End Turn
  → battle.end_turn() emits player_state_machine.turn_ended

PlayerTurn (connected to turn_ended in enter(), disconnected in exit())
  → _on_turn_ended() fires
  → battle_state_machine.transition_to(enemy_turn)

EnemyTurn.enter()
  → waits 1 second
  → battle_state_machine.transition_to(player_turn)

PlayerTurn.enter()
  → connects to turn_ended again
  → player_state_machine.transition_to(player_idle)
```

Any player state can end the turn by emitting `player_state_machine.turn_ended` — for example when the player runs out of moves — without needing to know about `BattleStateMachine`.

### State Base Classes

Each state machine has its own base class:

- `BattleBaseState` — exports `battle: Node` and `battle_state_machine: Node`
- `PlayerBaseState` — exports `battle: Node` and `player_state_machine: Node`

References are assigned as NodePaths in the Godot editor Inspector and stored in `battle.tscn`. All states extend their respective base class.

### Adding a New State

1. Create a script extending `BattleBaseState` or `PlayerBaseState`
2. Add a Node child to the relevant state machine in the scene
3. Assign `battle` and the state machine reference in the Inspector
4. Implement `enter()`, `exit()`, and `handle_input(event)`
5. Add an `@onready` var for it in the state machine script

### Coordinate System

The battle scene uses an isometric tile map with:
- Tile shape: Isometric (tile_shape = 1)
- Tile size: 64x32 pixels
- Helper functions for conversion:
  - `grid_tiles.map_to_local(grid_pos)` - converts grid coords to world position
  - `grid_tiles.local_to_map(world_pos)` - converts world position to grid coords
  - `grid_tiles.get_cell_tile_data(grid_pos)` - validates if a tile exists

### Physics Layers

Defined in project.godot:
- Layer 1: World
- Layer 2: Player
- Layer 3: Enemy

### Player/Enemy Characters

Both are `CharacterBody2D` scenes. The player script is currently minimal. They are positioned by the battle controller, not by their own scripts.

## Current State & Known Gaps

- Enemy AI is a placeholder (just waits 1 second)
- `player_attacking.gd` and `player_targetting.gd` are stubs
- `edge_distance()` is defined but not yet used for combat range checks
- `_on_attack_btn_pressed()` in battle.gd is a stub
