# Pause Menu Troubleshooting

## Testing the Pause Menu

1. **Run the game** and navigate to the tutorial scene
2. **Press ESC key** - you should see debug messages in the console:
   - "PauseMenu: Ready! Process mode set to ALWAYS" (when scene loads)
   - "PauseMenu: ESC key detected! Current visible state: false" (when you press ESC)
   - "PauseMenu: Showing pause menu" (when menu opens)

3. **Check the console output** - if you don't see these messages, the pause menu might not be instantiated

## Common Issues

### Issue 1: No debug messages appear
**Cause**: The pause menu scene is not properly instantiated
**Solution**: 
- Open `scenes/ui/tutorial_start.tscn` in Godot editor
- Check if "PauseMenu" node exists in the scene tree
- If not, manually add it: Scene → Instance Child Scene → select `scenes/ui/pause_menu.tscn`

### Issue 2: ESC key not detected
**Cause**: Input might be consumed by another node
**Solution**:
- The pause menu uses `_input()` which should receive input before other nodes
- Make sure no other script is calling `get_viewport().set_input_as_handled()` for ESC key

### Issue 3: Pause menu appears but game doesn't pause
**Cause**: Some nodes might have PROCESS_MODE_ALWAYS set
**Solution**:
- Check that player and other game nodes have default process mode (INHERIT)
- Only the pause menu should have PROCESS_MODE_ALWAYS

### Issue 4: Can't click buttons
**Cause**: Overlay might be blocking input
**Solution**:
- The ColorRect overlay should not have mouse_filter set to STOP
- Buttons should be in front of the overlay (they are in a CenterContainer)

## Manual Testing Steps

1. **Open Godot Editor**
2. **Open `scenes/ui/tutorial_start.tscn`**
3. **Check Scene Tree** - you should see:
   ```
   Tutorial_Village (Node2D)
   ├─ Map
   ├─ Player
   ├─ Matandang_Tagapayo
   ├─ Tutorial_Blocker
   ├─ Tutorial_UI (CanvasLayer)
   └─ PauseMenu (CanvasLayer) ← Should be here
   ```

4. **Run the scene** (F6)
5. **Press ESC** - pause menu should appear
6. **Check console** for debug messages

## If Still Not Working

Try this alternative approach - add the pause menu directly in the script:

1. Open `scripts/tutorial_start.gd`
2. Add at the top:
   ```gdscript
   const PAUSE_MENU = preload("res://scenes/ui/pause_menu.tscn")
   var pause_menu: CanvasLayer
   ```

3. In `_ready()` function, add:
   ```gdscript
   pause_menu = PAUSE_MENU.instantiate()
   add_child(pause_menu)
   ```

This will ensure the pause menu is always instantiated when the scene loads.
