# Skeleton Character Update

## Changes Made

### 1. Single Character for All Players
**Before:** Two different characters (Arin for male, Lira for female) with different sprites
**After:** Single skeleton character for all players regardless of gender selection

### 2. Character Assets
**Skeleton Character:**
- **Idle Animation:** `Skeleton - Base/Idle/Idle-Sheet.png` (32x32, 4 frames)
- **Run Animation:** `Skeleton - Base/Run/Run-Sheet.png` (32x32, 4 frames)
- **Location:** `assets/sprites/WorldAssets/Entities/Mobs/Skeleton Crew/Skeleton - Base/`

### 3. Gender Selection Simplified
**Before:**
- Showed character sprites (Arin and Lira)
- Buttons labeled "Arin (Male)" and "Lira (Female)"
- Info text: "You will play as [character]. [other] will be your companion."

**After:**
- No character sprites shown
- Simple buttons labeled "Boy" and "Girl"
- Question: "Are you a boy or a girl?"
- Info text: "You selected: Boy" or "You selected: Girl"

### 4. Animation System
The skeleton character uses two separate sprite sheets:
- **Idle:** Plays when standing still (frame 0 of idle sheet)
- **Run:** Plays when moving (cycles through 4 frames at 8 FPS)

The system automatically switches between idle and run animations based on player movement.

### 5. Files Modified

**scripts/tutorial_start.gd:**
- Removed Arin/Lira sprite paths and frame constants
- Added skeleton sprite paths (idle and run)
- Updated `_setup_player()` to load both idle and run atlases
- Updated `_tick_player_anim()` to switch between idle and run animations
- Removed gender-based character selection logic

**scripts/select_gender.gd:**
- Removed character sprite animation code
- Removed AtlasTexture setup for Arin and Lira
- Removed `_process()` function (no longer needed for sprite animation)
- Simplified button callbacks to just show "Boy" or "Girl"
- Updated info text to be simpler

**scenes/ui/select_gender.tscn:**
- Removed `MaleOption` and `FemaleOption` VBoxContainers
- Removed `ArinSprite` and `LiraSprite` TextureRect nodes
- Moved buttons directly under `GenderButtons` HBoxContainer
- Changed button text from "Arin (Male)" / "Lira (Female)" to "Boy" / "Girl"
- Updated question text to "Are you a boy or a girl?"

## Benefits

1. **Simpler Asset Management:** Only need one character sprite set instead of two
2. **Cleaner UI:** Gender selection is more straightforward without character previews
3. **Consistent Gameplay:** All players see the same character regardless of gender choice
4. **Easier Maintenance:** Less code to maintain for character animations
5. **Gender as Metadata:** Gender is now just a player attribute, not tied to visual appearance

## Gender Still Matters For:
- Story dialogue (pronouns, references)
- Companion assignment (if implemented)
- Player data tracking
- Save game information

## Testing
1. Start a new game
2. Enter a name
3. Select "Boy" or "Girl"
4. Verify the skeleton character appears in the tutorial scene
5. Test movement - skeleton should run when moving, idle when stopped
6. Verify sprite flips correctly when moving left/right

## Future Enhancements
If you want to add more skeleton variants:
- **Skeleton - Mage:** For magic-focused gameplay
- **Skeleton - Rogue:** For stealth-focused gameplay
- **Skeleton - Warrior:** For combat-focused gameplay

All variants have the same animation structure (Idle, Run, Death folders with sprite sheets).
