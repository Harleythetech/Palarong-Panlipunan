extends Node2D

# ─── Pause Menu ──────────────────────────────────────────────────────────────
const PAUSE_MENU_SCENE = preload("res://scenes/ui/pause_menu.tscn")
var _pause_menu: CanvasLayer

# ─── Skeleton Character (single character for all players) ───────────────────
const SKELETON_IDLE_PATH  := "res://assets/sprites/WorldAssets/Entities/Mobs/Skeleton Crew/Skeleton - Base/Idle/Idle-Sheet.png"
const SKELETON_RUN_PATH   := "res://assets/sprites/WorldAssets/Entities/Mobs/Skeleton Crew/Skeleton - Base/Run/Run-Sheet.png"
const SKELETON_DEATH_PATH := "res://assets/sprites/WorldAssets/Entities/Mobs/Skeleton Crew/Skeleton - Base/Death/Death-Sheet.png"

# Frame dimensions (different for each animation)
const SKELETON_IDLE_FRAME_W  := 32
const SKELETON_IDLE_FRAME_H  := 32
const SKELETON_IDLE_FRAMES   := 4

const SKELETON_RUN_FRAME_W   := 64  # Run frames are 64x64
const SKELETON_RUN_FRAME_H   := 64
const SKELETON_RUN_FRAMES    := 6   # Run has 6 frames (384/64 = 6)

const SKELETON_DEATH_FRAME_W := 64  # Death frames are 64x64
const SKELETON_DEATH_FRAME_H := 64  # Death frames height  
const SKELETON_DEATH_FRAMES  := 12  # Death has 12 frames
const SKELETON_DEATH_COLS    := 12  # 768/64 = 12 frames in one row

# ─── Player State Machine ────────────────────────────────────────────────────
enum PlayerState { IDLE, RUN, DEATH }
var _player_state: PlayerState = PlayerState.IDLE

# ─── Elder (Matandang Tagapayo) ───────────────────────────────────────────────
const ELDER_PATH        := "res://assets/sprites/medieval/elder.png"
const ELDER_FRAME_W     := 32
const ELDER_FRAME_H     := 32
const ELDER_FRAME_COUNT := 4

# ─── Tutorial Blocker (Amnesia's minion — Wizzard) ───────────────────────────
const BLOCKER_IDLE_PATH        := "res://assets/sprites/WorldAssets/Entities/Npc's/Wizzard/Idle/Idle-Sheet.png"
const BLOCKER_FRAME_W          := 32
const BLOCKER_FRAME_H          := 32
const BLOCKER_IDLE_FRAME_COUNT := 4

const MOVE_SPEED := 120.0
const WALK_FPS   := 8.0
const DEATH_FPS  := 6.0  # Slower animation for death (6 FPS instead of 8)

# ─── Dialogue ────────────────────────────────────────────────────────────────
const DIALOGUE_LINES := [
	"Matandang Tagapayo: {name}! Maligayang pagdating sa Isla ng Kaalaman.",
	"Matandang Tagapayo: Ninakaw ni Amnesia ang Aklat ng Kasaysayan. Unti-unting nawawala ang alaala ng ating mga tao.",
	"Matandang Tagapayo: Nakikita mo ang nilalang sa iyong harapan? Isa iyon sa mga alagad ni Amnesia.",
	"Matandang Tagapayo: Hindi sapat ang lakas lamang. Kailangan mo ng kaalaman upang matalo sila.",
	"Matandang Tagapayo: Maglakbay ka sa iba't ibang isla. Sagutin ang mga tanong — at mananalo ka. Handa ka na ba?",
]

enum State { EXPLORE, DIALOGUE, DONE }
var _state: State = State.EXPLORE

var _dialogue_index: int   = 0
var _typed_chars:    int   = 0
var _typing_timer:   float = 0.0
var _typing_done:    bool  = false
var _current_line:   String = ""

# ─── Player anim state ───────────────────────────────────────────────────────
var _player_anim_frame:  int   = 0
var _player_anim_timer:  float = 0.0
var _player_idle_atlas:  AtlasTexture
var _player_run_atlas:   AtlasTexture
var _player_death_atlas: AtlasTexture
var _death_anim_finished: bool = false

# ─── Elder anim state ────────────────────────────────────────────────────────
var _elder_anim_timer: float = 0.0
var _elder_anim_frame: int   = 0
var _elder_atlas:      AtlasTexture

# ─── Blocker anim state ──────────────────────────────────────────────────────
var _blocker_anim_timer: float = 0.0
var _blocker_anim_frame: int   = 0
var _blocker_atlas:      AtlasTexture

# ─── Node refs ───────────────────────────────────────────────────────────────
@onready var _player:         CharacterBody2D = $Player
@onready var _player_sprite:  Sprite2D        = $Player/Sprite2D
@onready var _elder_area:     Area2D          = $Matandang_Tagapayo
@onready var _elder_sprite:   Sprite2D        = $Matandang_Tagapayo/Sprite2D
@onready var _blocker_sprite: Sprite2D        = $Tutorial_Blocker/Sprite2D
@onready var _dialogue_box:   PanelContainer  = $Tutorial_UI/DialogueBox
@onready var _speaker_label:  Label           = $Tutorial_UI/DialogueBox/Margin/VBox/SpeakerLabel
@onready var _dialogue_label: RichTextLabel   = $Tutorial_UI/DialogueBox/Margin/VBox/DialogueLabel
@onready var _next_btn:       Button          = $Tutorial_UI/DialogueBox/Margin/VBox/NextButton
@onready var _hint_label:     Label           = $Tutorial_UI/HintLabel
@onready var _interact_hint:  Label           = $Tutorial_UI/InteractHint


func _ready() -> void:
	# Instantiate pause menu if not already in scene
	if not has_node("PauseMenu"):
		print("Tutorial: Pause menu not found in scene, instantiating manually")
		_pause_menu = PAUSE_MENU_SCENE.instantiate()
		add_child(_pause_menu)
	else:
		print("Tutorial: Pause menu found in scene")
		_pause_menu = $PauseMenu
	
	# Check if we're returning from settings
	if PlayerData.return_to_pause_menu:
		print("Tutorial: Returning from settings, showing pause menu")
		PlayerData.return_to_pause_menu = false  # Clear the flag
		# Show pause menu after a brief delay to ensure scene is ready
		await get_tree().process_frame
		if _pause_menu:
			_pause_menu.show_pause_menu()
	
	_setup_player()
	_setup_elder()
	_setup_blocker()
	_dialogue_box.visible  = false
	_hint_label.visible    = true
	_interact_hint.visible = false
	_elder_area.body_entered.connect(_on_elder_entered)
	_elder_area.body_exited.connect(_on_elder_exited)
	_next_btn.pressed.connect(_on_next_pressed)
	_next_btn.mouse_entered.connect(UiSfxManager.play_hover)


func _setup_player() -> void:
	print("Tutorial: Setting up player skeleton sprites...")
	print("Tutorial: Player sprite node: ", _player_sprite, " visible: ", _player_sprite.visible, " modulate: ", _player_sprite.modulate)
	
	# Setup idle animation (32x32 frames)
	_player_idle_atlas = AtlasTexture.new()
	var idle_texture = load(SKELETON_IDLE_PATH)
	if idle_texture == null:
		push_error("Failed to load skeleton idle sprite: " + SKELETON_IDLE_PATH)
		return
	_player_idle_atlas.atlas = idle_texture
	_player_idle_atlas.region = Rect2(0, 0, SKELETON_IDLE_FRAME_W, SKELETON_IDLE_FRAME_H)
	print("Tutorial: Idle atlas loaded, size: ", idle_texture.get_size(), " frame: ", SKELETON_IDLE_FRAME_W, "x", SKELETON_IDLE_FRAME_H)
	
	# Setup run animation (64x64 frames)
	_player_run_atlas = AtlasTexture.new()
	var run_texture = load(SKELETON_RUN_PATH)
	if run_texture == null:
		push_error("Failed to load skeleton run sprite: " + SKELETON_RUN_PATH)
		return
	_player_run_atlas.atlas = run_texture
	_player_run_atlas.region = Rect2(0, 0, SKELETON_RUN_FRAME_W, SKELETON_RUN_FRAME_H)
	print("Tutorial: Run atlas loaded, size: ", run_texture.get_size(), " frame: ", SKELETON_RUN_FRAME_W, "x", SKELETON_RUN_FRAME_H)
	
	# Setup death animation (64x64 frames)
	_player_death_atlas = AtlasTexture.new()
	var death_texture = load(SKELETON_DEATH_PATH)
	if death_texture == null:
		push_error("Failed to load skeleton death sprite: " + SKELETON_DEATH_PATH)
		return
	_player_death_atlas.atlas = death_texture
	_player_death_atlas.region = Rect2(0, 0, SKELETON_DEATH_FRAME_W, SKELETON_DEATH_FRAME_H)
	print("Tutorial: Death atlas loaded, size: ", death_texture.get_size(), " frame: ", SKELETON_DEATH_FRAME_W, "x", SKELETON_DEATH_FRAME_H)
	
	# Set initial texture and state
	_player_sprite.texture = _player_idle_atlas
	_player_state = PlayerState.IDLE
	_player_sprite.visible = true  # Ensure sprite is visible
	print("Tutorial: Player setup complete - Idle sprite should be visible now")


func _setup_elder() -> void:
	_elder_atlas = AtlasTexture.new()
	_elder_atlas.atlas  = load(ELDER_PATH)
	_elder_atlas.region = Rect2(0, 0, ELDER_FRAME_W, ELDER_FRAME_H)
	_elder_sprite.texture = _elder_atlas


func _setup_blocker() -> void:
	_blocker_atlas = AtlasTexture.new()
	_blocker_atlas.atlas  = load(BLOCKER_IDLE_PATH)
	_blocker_atlas.region = Rect2(0, 0, BLOCKER_FRAME_W, BLOCKER_FRAME_H)
	_blocker_sprite.texture = _blocker_atlas


func _physics_process(delta: float) -> void:
	_tick_elder_anim(delta)
	_tick_blocker_anim(delta)
	
	# Debug: Press K to test death animation
	if Input.is_key_pressed(KEY_K) and _player_state != PlayerState.DEATH:
		print("Tutorial: Triggering death animation (debug)")
		kill_player()
	
	# Debug: Press R to respawn
	if Input.is_key_pressed(KEY_R) and _player_state == PlayerState.DEATH:
		print("Tutorial: Respawning player (debug)")
		_change_player_state(PlayerState.IDLE)
	
	if _state == State.DIALOGUE:
		_player.velocity = Vector2.ZERO
		_player.move_and_slide()
		_tick_typing(delta)
		return
	_handle_movement(delta)


func _handle_movement(delta: float) -> void:
	# Don't allow movement if dead, but still animate
	if _player_state == PlayerState.DEATH:
		_player.velocity = Vector2.ZERO
		_player.move_and_slide()
		_tick_player_anim(delta)  # Still animate death
		return
	
	var dir := Vector2.ZERO
	if Input.is_action_pressed("ui_left")  or Input.is_key_pressed(KEY_A): dir.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D): dir.x += 1
	if Input.is_action_pressed("ui_up")    or Input.is_key_pressed(KEY_W): dir.y -= 1
	if Input.is_action_pressed("ui_down")  or Input.is_key_pressed(KEY_S): dir.y += 1

	var is_moving := dir.length() > 0

	if is_moving:
		dir = dir.normalized()
		_player.velocity = dir * MOVE_SPEED
		# Flip sprite based on horizontal movement direction
		# flip_h = false means facing left (default), flip_h = true means facing right
		if dir.x < 0:
			_player_sprite.flip_h = true  # Moving left, face left
		elif dir.x > 0:
			_player_sprite.flip_h = false   # Moving right, face right
		
		# Change to RUN state
		if _player_state != PlayerState.RUN:
			_change_player_state(PlayerState.RUN)
	else:
		_player.velocity = Vector2.ZERO
		
		# Change to IDLE state
		if _player_state != PlayerState.IDLE:
			_change_player_state(PlayerState.IDLE)

	_player.move_and_slide()
	_tick_player_anim(delta)

	if _interact_hint.visible:
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
			_start_dialogue()


func _change_player_state(new_state: PlayerState) -> void:
	if _player_state == new_state:
		return
	
	print("Tutorial: Changing player state from ", _player_state, " to ", new_state)
	_player_state = new_state
	_player_anim_frame = 0
	_player_anim_timer = 0.0
	
	match new_state:
		PlayerState.IDLE:
			_player_sprite.texture = _player_idle_atlas
			_player_idle_atlas.region = Rect2(0, 0, SKELETON_IDLE_FRAME_W, SKELETON_IDLE_FRAME_H)
			_player_sprite.scale = Vector2(3, 3)
			_player_sprite.offset = Vector2(0, 0)  # Reset offset for 32x32 sprite
		PlayerState.RUN:
			_player_sprite.texture = _player_run_atlas
			_player_run_atlas.region = Rect2(0, 0, SKELETON_RUN_FRAME_W, SKELETON_RUN_FRAME_H)
			_player_sprite.scale = Vector2(3, 3)
			# Offset to keep the sprite centered: (64-32)/2 = 16 pixels down
			_player_sprite.offset = Vector2(0, -16)  # Move sprite up to compensate for larger frame
		PlayerState.DEATH:
			_player_sprite.texture = _player_death_atlas
			_player_death_atlas.region = Rect2(0, 0, SKELETON_DEATH_FRAME_W, SKELETON_DEATH_FRAME_H)
			_player_sprite.scale = Vector2(3, 3)
			# Death frames are 32x64, so offset to align with 32x32 idle
			_player_sprite.offset = Vector2(0, -16)  # Move up by (64-32)/2 = 16
			_death_anim_finished = false


func _tick_player_anim(delta: float) -> void:
	match _player_state:
		PlayerState.IDLE:
			_animate_idle(delta)
		PlayerState.RUN:
			_animate_run(delta)
		PlayerState.DEATH:
			_animate_death(delta)


func _animate_idle(delta: float) -> void:
	_player_anim_timer += delta
	if _player_anim_timer >= 1.0 / WALK_FPS:
		_player_anim_timer -= 1.0 / WALK_FPS
		_player_anim_frame = (_player_anim_frame + 1) % SKELETON_IDLE_FRAMES
		var new_region = Rect2(
			_player_anim_frame * SKELETON_IDLE_FRAME_W, 0,
			SKELETON_IDLE_FRAME_W, SKELETON_IDLE_FRAME_H
		)
		_player_idle_atlas.region = new_region


func _animate_run(delta: float) -> void:
	_player_anim_timer += delta
	if _player_anim_timer >= 1.0 / WALK_FPS:
		_player_anim_timer -= 1.0 / WALK_FPS
		_player_anim_frame = (_player_anim_frame + 1) % SKELETON_RUN_FRAMES
		var new_region = Rect2(
			_player_anim_frame * SKELETON_RUN_FRAME_W, 0,
			SKELETON_RUN_FRAME_W, SKELETON_RUN_FRAME_H
		)
		_player_run_atlas.region = new_region


func _animate_death(delta: float) -> void:
	if _death_anim_finished:
		return
	
	_player_anim_timer += delta
	if _player_anim_timer >= 1.0 / DEATH_FPS:  # Use slower FPS for death
		_player_anim_timer -= 1.0 / DEATH_FPS
		_player_anim_frame += 1
		
		if _player_anim_frame >= SKELETON_DEATH_FRAMES:
			# Death animation finished, stay on last frame
			_player_anim_frame = SKELETON_DEATH_FRAMES - 1
			_death_anim_finished = true
		
		# Single row layout with 64x64 frames
		var frame_x = _player_anim_frame * SKELETON_DEATH_FRAME_W
		var frame_y = 0
		
		var new_region = Rect2(
			frame_x, frame_y,
			SKELETON_DEATH_FRAME_W, SKELETON_DEATH_FRAME_H
		)
		_player_death_atlas.region = new_region


# Public function to trigger death (can be called from damage/combat system)
func kill_player() -> void:
	_change_player_state(PlayerState.DEATH)


# Public function to check if player is dead
func is_player_dead() -> bool:
	return _player_state == PlayerState.DEATH


func _tick_elder_anim(delta: float) -> void:
	_elder_anim_timer += delta
	if _elder_anim_timer >= 1.0 / 6.0:
		_elder_anim_timer -= 1.0 / 6.0
		_elder_anim_frame = (_elder_anim_frame + 1) % ELDER_FRAME_COUNT
		_elder_atlas.region = Rect2(
			_elder_anim_frame * ELDER_FRAME_W, 0,
			ELDER_FRAME_W, ELDER_FRAME_H
		)


func _tick_blocker_anim(delta: float) -> void:
	_blocker_anim_timer += delta
	if _blocker_anim_timer >= 1.0 / 6.0:
		_blocker_anim_timer -= 1.0 / 6.0
		_blocker_anim_frame = (_blocker_anim_frame + 1) % BLOCKER_IDLE_FRAME_COUNT
		_blocker_atlas.region = Rect2(
			_blocker_anim_frame * BLOCKER_FRAME_W, 0,
			BLOCKER_FRAME_W, BLOCKER_FRAME_H
		)


func _start_dialogue() -> void:
	_state = State.DIALOGUE
	_hint_label.visible    = false
	_interact_hint.visible = false
	_dialogue_box.visible  = true
	_dialogue_index = 0
	_show_line(0)


func _show_line(idx: int) -> void:
	var raw: String = DIALOGUE_LINES[idx].replace("{name}", PlayerData.player_name)
	var colon: int  = raw.find(": ")
	if colon != -1:
		_speaker_label.text = raw.left(colon)
		_current_line       = raw.substr(colon + 2)
	else:
		_speaker_label.text = ""
		_current_line       = raw
	_dialogue_label.text = ""
	_typed_chars  = 0
	_typing_timer = 0.0
	_typing_done  = false
	_next_btn.visible = false


func _tick_typing(delta: float) -> void:
	if _typing_done:
		return
	var speed := SettingsManager.get_text_speed_value()
	if speed == 0.0:
		_dialogue_label.text = _current_line
		_typed_chars = _current_line.length()
		_typing_done = true
		_next_btn.visible = true
		return
	_typing_timer += delta
	while _typing_timer >= speed and _typed_chars < _current_line.length():
		_typing_timer -= speed
		_typed_chars  += 1
		_dialogue_label.text = _current_line.left(_typed_chars)
	if _typed_chars >= _current_line.length():
		_typing_done = true
		_next_btn.visible = true


func _on_next_pressed() -> void:
	UiSfxManager.play_confirm()
	if not _typing_done:
		_dialogue_label.text = _current_line
		_typed_chars = _current_line.length()
		_typing_done = true
		_next_btn.visible = true
		return
	_dialogue_index += 1
	if _dialogue_index < DIALOGUE_LINES.size():
		_show_line(_dialogue_index)
	else:
		_finish_tutorial()


func _finish_tutorial() -> void:
	_state = State.DONE
	_dialogue_box.visible = false
	PlayerData.location = "Tutorial_Village"
	SaveManager.save_game(PlayerData.current_slot)
	SceneTransition.change_scene("res://scenes/ui/tutorial_placeholder.tscn")


func _on_elder_entered(body: Node2D) -> void:
	if body == _player and _state == State.EXPLORE:
		_interact_hint.visible = true


func _on_elder_exited(body: Node2D) -> void:
	if body == _player:
		_interact_hint.visible = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == _player and _state == State.EXPLORE:
		_state = State.DONE
		print("Someone Entered the cave!")
