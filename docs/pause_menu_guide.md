# Pause Menu Guide

## Overview
The pause menu provides players with options to pause gameplay, adjust settings, save progress, return to the main menu, or quit the game.

## Features

### Main Menu Options
1. **Resume** - Returns to gameplay
2. **Settings** - Opens the game settings menu
3. **Save Game** - Saves current progress to the active save slot
4. **Main Menu** - Returns to main menu (with confirmation)
5. **Quit Game** - Exits the application (with confirmation)

### Activation
- Press **ESC** key to open/close the pause menu
- When the pause menu is open, the game tree is paused
- The pause menu itself continues to process (PROCESS_MODE_ALWAYS)

### Confirmation Dialogs
- **Main Menu Warning**: Confirms before returning to main menu to prevent accidental progress loss
- **Quit Warning**: Confirms before quitting the game

## Implementation Details

### Files
- `scripts/pause_menu.gd` - Pause menu logic and input handling
- `scenes/ui/pause_menu.tscn` - Pause menu UI scene

### Integration
The pause menu is integrated into game scenes as a CanvasLayer child node:

```gdscript
[node name="PauseMenu" parent="." instance=ExtResource("7_pause")]
```

### UI Style
The pause menu follows the existing UI design patterns:
- Uses KennyMain theme with pixel adventure aesthetic
- Semi-transparent dark overlay (Color(0, 0, 0, 0.7))
- Centered panel with buttons (350x48 minimum size)
- Font size 20 for main buttons
- Hover and focus audio cues via UiSfxManager

### Pause Behavior
When the pause menu is shown:
```gdscript
get_tree().paused = true
```

When hidden:
```gdscript
get_tree().paused = false
```

The pause menu node has `process_mode = PROCESS_MODE_ALWAYS` to continue processing while the game is paused.

## Usage in Other Scenes

To add the pause menu to a new scene:

1. Instance the pause menu scene:
   ```
   [node name="PauseMenu" parent="." instance=ExtResource("pause_menu_path")]
   ```

2. The pause menu will automatically handle ESC key input and pause/resume functionality

3. Optional: Connect to signals for custom behavior:
   ```gdscript
   $PauseMenu.resume_requested.connect(_on_pause_resume)
   $PauseMenu.main_menu_requested.connect(_on_pause_main_menu)
   $PauseMenu.quit_requested.connect(_on_pause_quit)
   ```

## Notes
- The Settings button temporarily unpauses the game to allow the settings scene to load
- Save functionality requires PlayerData.current_slot to be set
- All UI interactions include hover/focus audio feedback
- Confirmation dialogs prevent accidental navigation away from gameplay
