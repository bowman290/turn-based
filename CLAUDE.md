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
    battle.gd             # Main battle scene controller (data + shared utilities)
    state_machine.gd      # Manages state transitions and delegates input to current state
    states/
      base_state.gd       # Base class all states extend; sets battle/state_machine refs in _ready()
      player_idle.gd      # Waiting for player input; routes clicks to move or attack
      player_moving.gd    # Tween animation playing; ignores input until complete
      enemy_turn.gd       # Enemy acting; resets player resources then returns to PlayerIdle

scenes/
  levels/battle.tscn      # Main battle scene with tilemap, UI, and combat setup
  players/
    player.tscn           # Player character scene
    enemy.tscn            # Enemy character scene

assets/
  battle/                 # Tile sprites for isometric grid
  sprite_sheets/          # Character sprites
```

## Core Architecture

### Battle System (scripts/battle/battle.gd)

`battle.gd` is the data owner and utility layer. It does not contain turn or input logic directly — that lives in the state machine. It manages:

1. **Shared State**: Player/enemy grid positions, health, moves remaining, attack flag
2. **Grid Helpers**: Conversion between grid coordinates (Vector2i) and world positions
3. **UI Updates**: Health bars, turn label, moves label, target highlights
4. **Combat Utilities**: `melee_attack()`, `is_adjacent_space()`, `edge_distance()`
5. **Input Entry Point**: `_unhandled_input` validates the clicked tile then delegates to `state_machine.handle_click(grid_pos)`

### State Machine (scripts/battle/state_machine.gd)

Holds a reference to `current_state` and exposes two methods:
- `transition_to(new_state)` — calls `exit()` on the old state, `enter()` on the new
- `handle_click(grid_pos)` — forwards the click to `current_state.handle_click()`

States are child nodes of `StateMachine` in the scene tree. Each state sets its own `battle` and `state_machine` references via `get_parent()` in `base_state._ready()`.

### States

| State | Enter behaviour | Click behaviour |
|---|---|---|
| `PlayerIdle` | Updates turn label and target highlights | Routes to `_try_move` or `_try_attack` |
| `PlayerMoving` | Starts movement tween; transitions to `PlayerIdle` on finish | Ignored |
| `EnemyTurn` | Resets moves/attack flag, waits 1s, transitions to `PlayerIdle` | Ignored |

To add a new state: create a script extending `base_state.gd`, add a Node child to `StateMachine` in the scene, implement `enter()`, `exit()`, and `handle_click()`.

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
- `edge_distance()` is defined but not yet used for combat range checks
- `_on_attack_btn_pressed()` in battle.gd is a stub
