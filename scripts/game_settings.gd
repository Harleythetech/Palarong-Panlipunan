extends Control

const VOLUME_LABELS := ["Mute", "Low", "Medium", "High"]
const TEXT_SPEED_LABELS := ["Slow", "Normal", "Fast", "Instant"]
const TEXT_SIZE_LABELS := ["Small", "Normal", "Large"]

@onready var music_option: OptionButton = %MusicOption
@onready var sfx_option: OptionButton = %SFXOption
@onready var text_speed_option: OptionButton = %TextSpeedOption
@onready var text_size_option: OptionButton = %TextSizeOption
@onready var dyslexia_toggle: CheckButton = %DyslexiaToggle
@onready var hints_toggle: CheckButton = %HintsToggle
@onready var _margin: MarginContainer = $MarginContainer


func _ready() -> void:
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


func _load_current_settings() -> void:
	music_option.selected = SettingsManager.music_volume
	sfx_option.selected = SettingsManager.sfx_volume
	text_speed_option.selected = SettingsManager.text_speed
	text_size_option.selected = SettingsManager.text_size
	dyslexia_toggle.button_pressed = SettingsManager.dyslexia_font
	hints_toggle.button_pressed = SettingsManager.show_hints


func _on_back_pressed() -> void:
	SettingsManager.save_settings()
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
