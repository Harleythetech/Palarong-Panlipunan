# Pause Menu Settings Navigation Fix

## Problem
When opening Settings from the Pause Menu and pressing Back, the game would return to the Main Menu instead of returning to the Pause Menu, preventing the player from resuming gameplay.

## Solution
Implemented a state tracking system to detect where Settings was opened from (Main Menu vs Pause Menu) and return to the appropriate location.

## Implementation Details

### 1. Added State Tracking to game_settings.gd
```gdscript
enum SettingsSource { MAIN_MENU, PAUSE_MENU }
var return_to_source: SettingsSource = SettingsSource.MAIN_MENU
```

### 2. Detection Logic in _ready()
The settings screen now detects its source by checking if the game is paused:
- If `get_tree().paused == true` → Opened from Pause Menu
- If `get_tree().paused == false` → Opened from Main Menu

### 3. Added Scene Path Tracking to PlayerData
```gdscript
var last_scene_path: String = ""  # Track the last game scene
var return_to_pause_menu: bool = false  # Flag to reopen pause menu
```

### 4. Pause Menu Stores Context
When Settings button is pressed in the pause menu:
```gdscript
PlayerData.last_scene_path = get_tree().current_scene.scene_file_path
PlayerData.return_to_pause_menu = true
```

### 5. Settings Back Button Logic
```gdscript
if return_to_source == SettingsSource.PAUSE_MENU:
    # Return to the game scene
    get_tree().change_scene_to_file(PlayerData.last_scene_path)
else:
    # Return to main menu
    get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
```

### 6. Game Scene Reopens Pause Menu
When the game scene loads and detects `PlayerData.return_to_pause_menu == true`:
```gdscript
if PlayerData.return_to_pause_menu:
    PlayerData.return_to_pause_menu = false
    await get_tree().process_frame
    _pause_menu.show_pause_menu()
```

## Flow Diagram

### From Main Menu:
```
Main Menu → Settings → Back → Main Menu ✓
```

### From Pause Menu:
```
Game → ESC (Pause) → Settings → Back → Game (Paused) ✓
```

## Files Modified
1. `scripts/game_settings.gd` - Added source detection and conditional return logic
2. `scripts/pause_menu.gd` - Store scene path before opening settings
3. `scripts/player_data.gd` - Added state tracking variables
4. `scripts/tutorial_start.gd` - Reopen pause menu when returning from settings

## Testing
1. **Test from Main Menu:**
   - Main Menu → Options → Back → Should return to Main Menu

2. **Test from Pause Menu:**
   - Start game → Press ESC → Settings → Back → Should return to Pause Menu
   - Press ESC again or click Resume → Should return to gameplay

## Debug Output
The implementation includes debug prints to help track the flow:
- "GameSettings: Opened from PAUSE_MENU" or "Opened from MAIN_MENU"
- "PauseMenu: Storing scene path: [path]"
- "GameSettings: Returning to pause menu" or "Returning to main menu"
- "Tutorial: Returning from settings, showing pause menu"
