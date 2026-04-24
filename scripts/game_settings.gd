extends Control

# Track where settings was opened from
enum SettingsSource { MAIN_MENU, PAUSE_MENU }
var return_to_source: SettingsSource = SettingsSource.MAIN_MENU

const VOLUME_LABELS := ["Mute", "Low", "Medium", "High"]
const TEXT_SPEED_LABELS := ["Slow", "Normal", "Fast", "Instant"]
const TEXT_SIZE_LABELS := ["Small", "Normal", "Large"]
const INFO_TEXT := [
	"Toggle a font designed to be easier to read for people with dyslexia. May not work with all text sizes.",
	"Show hints during gameplay.",
	"Adjust the text size. Larger sizes may cause text to overflow in some areas.",
	"Adjust the text speed. Faster speeds may be harder to read.",
	"Adjust the music volume.",
	"Adjust the sound effects volume."
]

@onready var music_option: OptionButton = %MusicOption
@onready var sfx_option: OptionButton = %SFXOption
@onready var text_speed_option: OptionButton = %TextSpeedOption
@onready var text_size_option: OptionButton = %TextSizeOption
@onready var dyslexia_toggle: CheckButton = %DyslexiaToggle
@onready var hints_toggle: CheckButton = %HintsToggle
@onready var _margin: MarginContainer = $MarginContainer
@onready var Info_label: Label = $MarginContainer/Layout/InfoCard/MarginContainer/InfoLabel


func _ready() -> void:
	# Check if we came from pause menu using the flag
	if PlayerData.return_to_pause_menu:
		return_to_source = SettingsSource.PAUSE_MENU
		print("GameSettings: Opened from PAUSE_MENU (flag detected)")
	else:
		return_to_source = SettingsSource.MAIN_MENU
		print("GameSettings: Opened from MAIN_MENU")
	
	_populate_options()
	_load_current_settings()
	_adapt_layout()
	resized.connect(_adapt_layout)


func _adapt_layout() -> void:
	var vp_size := get_viewport_rect().size
	var w := vp_size.x

	var margin_val: int
	if w < 600:
		margin_val = 10
	elif w < 1200:
		margin_val = 20
	else:
		margin_val = 40

	_margin.add_theme_constant_override("margin_left", margin_val)
	_margin.add_theme_constant_override("margin_top", margin_val)
	_margin.add_theme_constant_override("margin_right", margin_val)
	_margin.add_theme_constant_override("margin_bottom", margin_val)


func _populate_options() -> void:
	for label in VOLUME_LABELS:
		music_option.add_item(label)
		sfx_option.add_item(label)
	for label in TEXT_SPEED_LABELS:
		text_speed_option.add_item(label)
	for label in TEXT_SIZE_LABELS:
		text_size_option.add_item(label)

########################################
# Settings Loader
# This section loads the current settings from the SettingsManager and updates the UI elements to reflect those settings when the scene is ready.
########################################

func _load_current_settings() -> void:
	music_option.selected = SettingsManager.music_volume
	sfx_option.selected = SettingsManager.sfx_volume
	text_speed_option.selected = SettingsManager.text_speed
	text_size_option.selected = SettingsManager.text_size
	dyslexia_toggle.button_pressed = SettingsManager.dyslexia_font
	hints_toggle.button_pressed = SettingsManager.show_hints


########################################
# SETTINGS INTERACTIONS
# These functions are called when the user interacts with the different settings options. They update the SettingsManager with the new values and apply changes immediately for audio and fonts.
########################################

func _on_back_pressed() -> void:
	UiSfxManager.play_confirm()
	SettingsManager.save_settings()
	
	print("GameSettings: return_to_source = ", return_to_source)
	print("GameSettings: PlayerData.return_to_pause_menu = ", PlayerData.return_to_pause_menu)
	print("GameSettings: PlayerData.last_scene_path = ", PlayerData.last_scene_path)
	
	if return_to_source == SettingsSource.PAUSE_MENU:
		print("GameSettings: Returning to pause menu")
		# Return to the paused game scene
		get_tree().change_scene_to_file(PlayerData.last_scene_path if PlayerData.last_scene_path else "res://scenes/ui/tutorial_start.tscn")
	else:
		print("GameSettings: Returning to main menu")
		PlayerData.return_to_pause_menu = false  # Clear the flag
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_music_option_selected(index: int) -> void:
	SettingsManager.music_volume = index
	SettingsManager.apply_audio()


func _on_sfx_option_selected(index: int) -> void:
	SettingsManager.sfx_volume = index
	SettingsManager.apply_audio()


func _on_text_speed_selected(index: int) -> void:
	SettingsManager.text_speed = index


func _on_text_size_selected(index: int) -> void:
	SettingsManager.text_size = index
	SettingsManager.apply_text_size()


func _on_dyslexia_toggled(toggled_on: bool) -> void:
	SettingsManager.dyslexia_font = toggled_on
	SettingsManager.apply_fonts()


func _on_hints_toggled(toggled_on: bool) -> void:
	SettingsManager.show_hints = toggled_on


########################################
# INFO CARD INTERACTIONS
# These functions are used to update the info card on the right side of the screen when the user interacts with different settings.
########################################

# Music Volume

func _on_music_volume_focus_entered() -> void:
	Info_label.text = INFO_TEXT[4]

func _on_music_volume_mouse_entered() -> void:
	Info_label.text = INFO_TEXT[4]

# SFX Volume

func _on_sfx_volume_mouse_entered() -> void:
	Info_label.text = INFO_TEXT[5]

func _on_sfx_volume_focus_entered() -> void:
	Info_label.text = INFO_TEXT[5]

# Text Speed

func _on_text_speed_mouse_entered() -> void:
	Info_label.text = INFO_TEXT[3]

func _on_text_speed_focus_entered() -> void:
	Info_label.text = INFO_TEXT[3]

# Adjust Text Size

func _on_text_size_mouse_entered() -> void:
	Info_label.text = INFO_TEXT[2]

func _on_text_size_focus_entered() -> void:
	Info_label.text = INFO_TEXT[2]

# Dyslexia Font

func _on_dyslexia_font_focus_entered() -> void:
	Info_label.text = INFO_TEXT[0]


func _on_dyslexia_font_mouse_entered() -> void:
	Info_label.text = INFO_TEXT[0]

# Show Hints

func _on_show_hints_mouse_entered() -> void:
	Info_label.text = INFO_TEXT[1]

func _on_show_hints_focus_entered() -> void:
	Info_label.text = INFO_TEXT[1]


# Hover Function for back Button : Game Sounds

func _on_back_button_mouse_entered() -> void:
	UiSfxManager.play_hover()

func _on_back_button_focus_entered() -> void:
	UiSfxManager.play_hover()
