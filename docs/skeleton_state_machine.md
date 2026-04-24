# Skeleton Character State Machine

## Overview
The skeleton character uses a state machine with three states: IDLE, RUN, and DEATH. Each state has its own animation and behavior.

## States

### 1. IDLE State
**When Active:**
- Player is not moving
- No input is being pressed

**Animation:**
- Uses `Idle-Sheet.png` (4 frames)
- Loops continuously at 8 FPS
- Cycles through all 4 frames

**Transitions:**
- To RUN: When player presses movement keys
- To DEATH: When `kill_player()` is called

### 2. RUN State
**When Active:**
- Player is moving in any direction
- Movement keys (WASD or Arrow keys) are pressed

**Animation:**
- Uses `Run-Sheet.png` (4 frames)
- Loops continuously at 8 FPS
- Cycles through all 4 frames

**Behavior:**
- Sprite flips horizontally based on movement direction
- Velocity is set to MOVE_SPEED (120.0) in the direction of input

**Transitions:**
- To IDLE: When player stops moving
- To DEATH: When `kill_player()` is called

### 3. DEATH State
**When Active:**
- Player has died (triggered by `kill_player()`)
- Cannot move or perform actions

**Animation:**
- Uses `Death-Sheet.png` (4 frames)
- Plays once at 8 FPS
- Stops on the last frame (frame 3)
- Does not loop

**Behavior:**
- Movement is disabled
- Velocity is set to zero
- Player cannot interact with anything
- Animation plays to completion then freezes

**Transitions:**
- No automatic transitions
- Can be reset by calling `_change_player_state(PlayerState.IDLE)` (for respawn)

## State Machine Implementation

### State Enum
```gdscript
enum PlayerState { IDLE, RUN, DEATH }
var _player_state: PlayerState = PlayerState.IDLE
```

### State Change Function
```gdscript
func _change_player_state(new_state: PlayerState) -> void
```
- Resets animation frame and timer
- Switches the sprite texture to the appropriate atlas
- Sets up the initial frame for the new state

### Animation Functions
Each state has its own animation function:
- `_animate_idle(delta)` - Loops idle animation
- `_animate_run(delta)` - Loops run animation
- `_animate_death(delta)` - Plays death animation once

### Public API
```gdscript
# Trigger death animation
func kill_player() -> void

# Check if player is dead
func is_player_dead() -> bool
```

## Debug Controls

For testing purposes, debug keys are available:

- **K Key:** Trigger death animation
- **R Key:** Respawn player (reset to IDLE state)

These are temporary debug features and should be removed or disabled in production.

## Animation Specifications

| State | Sprite Sheet | Frames | FPS | Loop |
|-------|-------------|--------|-----|------|
| IDLE  | Idle-Sheet.png | 4 | 8 | Yes |
| RUN   | Run-Sheet.png | 4 | 8 | Yes |
| DEATH | Death-Sheet.png | 4 | 8 | No |

All sprites are 32x32 pixels.

## Usage Examples

### Triggering Death
```gdscript
# From combat system or damage handler
if player_health <= 0:
    tutorial_scene.kill_player()
```

### Checking Death State
```gdscript
# Before allowing actions
if not tutorial_scene.is_player_dead():
    # Allow player to interact
    pass
```

### Respawning
```gdscript
# After respawn delay or at checkpoint
tutorial_scene._change_player_state(PlayerState.IDLE)
player_health = max_health
```

## State Transition Diagram

```
    ┌──────┐
    │ IDLE │ ◄─────────────┐
    └──┬───┘                │
       │                    │
       │ Movement Input     │ Stop Moving
       │                    │
       ▼                    │
    ┌──────┐                │
    │ RUN  │ ───────────────┘
    └──┬───┘
       │
       │ kill_player()
       │
       ▼
    ┌───────┐
    │ DEATH │ (Terminal state)
    └───────┘
```

## Future Enhancements

### Possible Additional States:
1. **ATTACK** - Combat animations
2. **HURT** - Damage reaction
3. **JUMP** - If platforming is added
4. **INTERACT** - Special interaction animations
5. **CAST** - Magic/ability animations

### Possible Improvements:
1. State transition callbacks for sound effects
2. Animation events for footsteps, impacts, etc.
3. State-specific collision behavior
4. Invincibility frames during certain states
5. Animation blending between states
