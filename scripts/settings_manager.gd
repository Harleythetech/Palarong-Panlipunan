extends Node

# Audio: 0=Mute, 1=Low, 2=Medium, 3=High
var music_volume: int = 2
var sfx_volume: int = 2

# Text: speed 0=Slow,1=Normal,2=Fast,3=Instant | size 0=Small,1=Normal,2=Large
var text_speed: int = 1
var text_size: int = 1
var dyslexia_font: bool = false

# Gameplay
var show_hints: bool = true

const VOLUME_DB := {0: - 80.0, 1: - 20.0, 2: - 10.0, 3: 0.0}
const TEXT_SPEED_VALUES := {0: 0.08, 1: 0.04, 2: 0.02, 3: 0.0}
const TEXT_SIZE_SCALE := {0: 1.0, 1: 1.3, 2: 1.6}
const DEFAULT_FONT_SIZE := 20

const SAVE_PATH := "user://settings.cfg"

signal settings_changed

var _default_font: Font = preload("res://assets/fonts/Schoolbell-Regular.ttf")
var _dyslexia_regular_font: Font = preload("res://assets/fonts/OpenDyslexic-Regular.otf")
var _dyslexia_bold_font: Font = preload("res://assets/fonts/OpenDyslexic-Bold.otf")
var _theme: Theme


func _ready() -> void:
	load_settings()
	_setup_theme()
	apply_audio()
	apply_fonts()
	apply_text_size()


func get_text_speed_value() -> float:
	return TEXT_SPEED_VALUES.get(text_speed, 0.04)


func get_text_size_scale() -> float:
	return TEXT_SIZE_SCALE.get(text_size, 1.0)


func apply_audio() -> void:
	_set_bus_volume("BGM", music_volume)
	_set_bus_volume("SFX", sfx_volume)


func _setup_theme() -> void:
	_theme = Theme.new()
	get_tree().root.theme = _theme
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if node is Control:
		var font: Font = _dyslexia_regular_font if dyslexia_font else _default_font
		var scale: float = get_text_size_scale()
		if node.has_theme_font_override("font"):
			node.add_theme_font_override("font", font)
		if node.has_theme_font_size_override("font_size"):
			var original: int = node.get_theme_font_size("font_size")
			node.set_meta("_base_font_size", original)
			node.add_theme_font_size_override("font_size", int(original * scale))


func apply_fonts() -> void:
	var font: Font
	if dyslexia_font:
		font = _dyslexia_regular_font
	else:
		font = _default_font
	_theme.default_font = font
	_update_font_overrides(get_tree().root, font)
	settings_changed.emit()


func _update_font_overrides(node: Node, font: Font) -> void:
	if node is Control and node.has_theme_font_override("font"):
		node.add_theme_font_override("font", font)
	for child in node.get_children():
		_update_font_overrides(child, font)


func apply_text_size() -> void:
	var scale: float = get_text_size_scale()
	_theme.default_font_size = int(DEFAULT_FONT_SIZE * scale)
	_update_font_size_overrides(get_tree().root, scale)
	settings_changed.emit()


func _update_font_size_overrides(node: Node, scale: float) -> void:
	if node is Control and node.has_theme_font_size_override("font_size"):
		var base_size: int
		if node.has_meta("_base_font_size"):
			base_size = node.get_meta("_base_font_size")
		else:
			base_size = node.get_theme_font_size("font_size")
			node.set_meta("_base_font_size", base_size)
		node.add_theme_font_size_override("font_size", int(base_size * scale))
	for child in node.get_children():
		_update_font_size_overrides(child, scale)


func get_current_font() -> Font:
	if dyslexia_font:
		return _dyslexia_regular_font
	return _default_font


func get_current_bold_font() -> Font:
	if dyslexia_font:
		return _dyslexia_bold_font
	return _default_font


func _set_bus_volume(bus_name: String, level: int) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	var db: float = VOLUME_DB.get(level, 0.0)
	AudioServer.set_bus_volume_db(idx, db)
	AudioServer.set_bus_mute(idx, level == 0)


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("reading", "text_speed", text_speed)
	config.set_value("reading", "text_size", text_size)
	config.set_value("reading", "dyslexia_font", dyslexia_font)
	config.set_value("gameplay", "show_hints", show_hints)
	config.save(SAVE_PATH)


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	music_volume = config.get_value("audio", "music_volume", 2)
	sfx_volume = config.get_value("audio", "sfx_volume", 2)
	text_speed = config.get_value("reading", "text_speed", 1)
	text_size = config.get_value("reading", "text_size", 1)
	dyslexia_font = config.get_value("reading", "dyslexia_font", false)
	show_hints = config.get_value("gameplay", "show_hints", true)
