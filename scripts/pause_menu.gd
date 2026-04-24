extends CanvasLayer

signal resume_requested
signal main_menu_requested
signal quit_requested

@onready var _resume_btn:     Button  = %ResumeButton
@onready var _settings_btn:   Button  = %SettingsButton
@onready var _save_btn:       Button  = %SaveButton
@onready var _main_menu_btn:  Button  = %MainMenuButton
@onready var _quit_btn:       Button  = %QuitButton
@onready var _main_menu_warn: Control = %MainMenuWarning
@onready var _quit_warn:      Control = %QuitWarning


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_connect_signals()
	print("PauseMenu: Ready! Process mode set to ALWAYS")


func _connect_signals() -> void:
	# Main buttons
	_resume_btn.pressed.connect(_on_resume_pressed)
	_resume_btn.mouse_entered.connect(UiSfxManager.play_hover)
	_resume_btn.focus_entered.connect(UiSfxManager.play_hover)
	
	_settings_btn.pressed.connect(_on_settings_pressed)
	_settings_btn.mouse_entered.connect(UiSfxManager.play_hover)
	_settings_btn.focus_entered.connect(UiSfxManager.play_hover)
	
	_save_btn.pressed.connect(_on_save_pressed)
	_save_btn.mouse_entered.connect(UiSfxManager.play_hover)
	_save_btn.focus_entered.connect(UiSfxManager.play_hover)
	
	_main_menu_btn.pressed.connect(_on_main_menu_pressed)
	_main_menu_btn.mouse_entered.connect(UiSfxManager.play_hover)
	_main_menu_btn.focus_entered.connect(UiSfxManager.play_hover)
	
	_quit_btn.pressed.connect(_on_quit_pressed)
	_quit_btn.mouse_entered.connect(UiSfxManager.play_hover)
	_quit_btn.focus_entered.connect(UiSfxManager.play_hover)
	
	# Main Menu warning buttons
	var mm_cancel: Button = %MainMenuCancelButton
	var mm_confirm: Button = %MainMenuConfirmButton
	mm_cancel.pressed.connect(_on_main_menu_cancel)
	mm_cancel.mouse_entered.connect(UiSfxManager.play_hover)
	mm_cancel.focus_entered.connect(UiSfxManager.play_hover)
	mm_confirm.pressed.connect(_on_main_menu_confirm)
	mm_confirm.mouse_entered.connect(UiSfxManager.play_hover)
	mm_confirm.focus_entered.connect(UiSfxManager.play_hover)
	
	# Quit warning buttons
	var quit_cancel: Button = %QuitCancelButton
	var quit_confirm: Button = %QuitConfirmButton
	quit_cancel.pressed.connect(_on_quit_cancel)
	quit_cancel.mouse_entered.connect(UiSfxManager.play_hover)
	quit_cancel.focus_entered.connect(UiSfxManager.play_hover)
	quit_confirm.pressed.connect(_on_quit_confirm)
	quit_confirm.mouse_entered.connect(UiSfxManager.play_hover)
	quit_confirm.focus_entered.connect(UiSfxManager.play_hover)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		print("PauseMenu: ESC key detected! Current visible state: ", visible)
		if visible:
			if _main_menu_warn.visible or _quit_warn.visible:
				return
			_on_resume_pressed()
		else:
			show_pause_menu()
		get_viewport().set_input_as_handled()


func show_pause_menu() -> void:
	print("PauseMenu: Showing pause menu")
	visible = true
	get_tree().paused = true
	_resume_btn.grab_focus()


func hide_pause_menu() -> void:
	print("PauseMenu: Hiding pause menu")
	visible = false
	get_tree().paused = false


func _on_resume_pressed() -> void:
	UiSfxManager.play_confirm()
	hide_pause_menu()
	resume_requested.emit()


func _on_settings_pressed() -> void:
	UiSfxManager.play_confirm()
	# Store the current scene path so settings can return here
	PlayerData.last_scene_path = get_tree().current_scene.scene_file_path
	PlayerData.return_to_pause_menu = true  # Flag to reopen pause menu when returning
	print("PauseMenu: Settings pressed")
	print("PauseMenu: Storing scene path: ", PlayerData.last_scene_path)
	print("PauseMenu: Setting return_to_pause_menu = ", PlayerData.return_to_pause_menu)
	get_tree().paused = false
	SceneTransition.change_scene("res://scenes/ui/game_settings.tscn")


func _on_save_pressed() -> void:
	UiSfxManager.play_confirm()
	if PlayerData.current_slot > 0:
		SaveManager.save_game(PlayerData.current_slot)
		# TODO: Show save confirmation feedback
		print("Game saved to slot ", PlayerData.current_slot)


func _on_main_menu_pressed() -> void:
	UiSfxManager.play_confirm()
	_main_menu_warn.visible = true


func _on_main_menu_cancel() -> void:
	UiSfxManager.play_confirm()
	_main_menu_warn.visible = false
	_main_menu_btn.grab_focus()


func _on_main_menu_confirm() -> void:
	UiSfxManager.play_confirm()
	get_tree().paused = false
	main_menu_requested.emit()
	SceneTransition.change_scene("res://scenes/ui/main_menu.tscn")


func _on_quit_pressed() -> void:
	UiSfxManager.play_confirm()
	_quit_warn.visible = true


func _on_quit_cancel() -> void:
	UiSfxManager.play_confirm()
	_quit_warn.visible = false
	_quit_btn.grab_focus()


func _on_quit_confirm() -> void:
	UiSfxManager.play_confirm()
	quit_requested.emit()
	get_tree().quit()
