# Settings Navigation & Font Debug Guide

## Issue 1: Settings Always Returns to Main Menu

### Debug Steps:
1. **Start the game** and enter the tutorial scene
2. **Press ESC** to open pause menu
3. **Click Settings**
4. **Check the console output** - you should see:
   ```
   PauseMenu: Storing scene path: res://scenes/ui/tutorial_start.tscn
   GameSettings: Opened from PAUSE_MENU (flag detected)
   ```

5. **Press Back** in settings
6. **Check the console output** - you should see:
   ```
   GameSettings: return_to_source = 1 (PAUSE_MENU)
   GameSettings: PlayerData.return_to_pause_menu = true
   GameSettings: PlayerData.last_scene_path = res://scenes/ui/tutorial_start.tscn
   GameSettings: Returning to pause menu
   ```

### If you see "Opened from MAIN_MENU" instead:
This means `PlayerData.return_to_pause_menu` is not being set correctly.

**Check:**
- Is the pause menu script being executed?
- Add a print statement in pause_menu.gd `_on_settings_pressed()` to verify it's called

### If you see "Returning to main menu" instead:
This means `return_to_source` is not being set to PAUSE_MENU.

**Possible causes:**
1. The flag `PlayerData.return_to_pause_menu` is being cleared before settings loads
2. The settings scene is loading before the flag is set
3. There's a timing issue with scene transitions

### Quick Fix Test:
Try adding this to the top of `_on_settings_pressed()` in pause_menu.gd:
```gdscript
print("PauseMenu: Settings button pressed")
print("PauseMenu: Setting return_to_pause_menu = true")
```

## Issue 2: Fonts Not Applying

### Debug Steps:
1. **Open Settings** (from main menu or pause menu)
2. **Toggle Dyslexia Font** ON
3. **Check console output** - you should see:
   ```
   SettingsManager: Applying dyslexia font
   ```

4. **Change Text Size** to Large
5. **Check console output** - you should see:
   ```
   SettingsManager: Applying text size scale: 1.6
   ```

### If fonts don't change:
The issue is likely that:
1. Font files are not loading correctly
2. The theme override is not being applied to existing nodes
3. Nodes are using a different theme that overrides the global theme

### Font File Check:
Verify these files exist:
- `res://assets/fonts/Schoolbell-Regular.ttf`
- `res://assets/fonts/OpenDyslexic-Regular.otf`
- `res://assets/fonts/OpenDyslexic-Bold.otf`

### Manual Test:
Add this to `_on_dyslexia_toggled()` in game_settings.gd:
```gdscript
print("Dyslexia toggle changed to: ", toggled_on)
print("Font being applied: ", SettingsManager._dyslexia_regular_font if toggled_on else SettingsManager._default_font)
```

## Expected Console Output Flow

### From Pause Menu to Settings and Back:
```
[Player presses ESC]
PauseMenu: ESC key detected! Current visible state: false
PauseMenu: Showing pause menu

[Player clicks Settings]
PauseMenu: Storing scene path: res://scenes/ui/tutorial_start.tscn
GameSettings: Opened from PAUSE_MENU (flag detected)

[Player clicks Back]
GameSettings: return_to_source = 1
GameSettings: PlayerData.return_to_pause_menu = true
GameSettings: PlayerData.last_scene_path = res://scenes/ui/tutorial_start.tscn
GameSettings: Returning to pause menu
Tutorial: Returning from settings, showing pause menu
PauseMenu: Showing pause menu
```

### From Main Menu to Settings and Back:
```
[Player clicks Options]
GameSettings: Opened from MAIN_MENU

[Player clicks Back]
GameSettings: return_to_source = 0
GameSettings: PlayerData.return_to_pause_menu = false
GameSettings: PlayerData.last_scene_path = 
GameSettings: Returning to main menu
```

## Troubleshooting Commands

If the issue persists, try these in the Godot debugger console:
```gdscript
# Check PlayerData state
print(PlayerData.return_to_pause_menu)
print(PlayerData.last_scene_path)

# Check if game is paused
print(get_tree().paused)

# Check current scene
print(get_tree().current_scene.scene_file_path)
```
