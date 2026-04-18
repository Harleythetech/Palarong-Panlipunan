extends Control

const ANIM_FPS := 6.0
const ARIN_FRAME_SIZE := Vector2(32, 32)
const ARIN_FRAME_COUNT := 4
const LIRA_FRAME_SIZE := Vector2(34, 34)
const LIRA_FRAME_COUNT := 5

var _selected_gender: String = ""
var _anim_timer: float = 0.0
var _anim_frame: int = 0
var _arin_atlas: AtlasTexture
var _lira_atlas: AtlasTexture

@onready var _margin: MarginContainer = $MarginContainer
@onready var _male_button: Button = $MarginContainer/Layout/ContentPanel/ContentMargin/VBoxContainer/GenderSection/GenderButtons/MaleOption/MaleButton
@onready var _female_button: Button = $MarginContainer/Layout/ContentPanel/ContentMargin/VBoxContainer/GenderSection/GenderButtons/FemaleOption/FemaleButton
@onready var _confirm_button: Button = $MarginContainer/Layout/ContentPanel/ContentMargin/VBoxContainer/ConfirmButton
@onready var _gender_label: Label = $MarginContainer/Layout/InfoCard/MarginContainer/GenderInfo
@onready var _name_display: Label = $MarginContainer/Layout/ContentPanel/ContentMargin/VBoxContainer/NameDisplay
@onready var _arin_sprite: TextureRect = $MarginContainer/Layout/ContentPanel/ContentMargin/VBoxContainer/GenderSection/GenderButtons/MaleOption/ArinSprite
@onready var _lira_sprite: TextureRect = $MarginContainer/Layout/ContentPanel/ContentMargin/VBoxContainer/GenderSection/GenderButtons/FemaleOption/LiraSprite
@onready var _info_card: PanelContainer = $MarginContainer/Layout/InfoCard


func _ready() -> void:
	_confirm_button.disabled = true
	_name_display.text = "Playing as: %s" % PlayerData.player_name

	_arin_atlas = AtlasTexture.new()
	_arin_atlas.atlas = load("res://assets/sprites/medieval/adventurer_03.png")
	_arin_atlas.region = Rect2(0, 0, ARIN_FRAME_SIZE.x, ARIN_FRAME_SIZE.y)
	_arin_sprite.texture = _arin_atlas

	_lira_atlas = AtlasTexture.new()
	_lira_atlas.atlas = load("res://assets/sprites/medieval/adventurer_02.png")
	_lira_atlas.region = Rect2(0, 0, LIRA_FRAME_SIZE.x, LIRA_FRAME_SIZE.y)
	_lira_sprite.texture = _lira_atlas

	_adapt_layout()
	resized.connect(_adapt_layout)


func _process(delta: float) -> void:
	_anim_timer += delta
	var frame_duration := 1.0 / ANIM_FPS
	if _anim_timer >= frame_duration:
		_anim_timer -= frame_duration
		_anim_frame += 1
		_arin_atlas.region = Rect2((_anim_frame % ARIN_FRAME_COUNT) * ARIN_FRAME_SIZE.x, 0, ARIN_FRAME_SIZE.x, ARIN_FRAME_SIZE.y)
		_lira_atlas.region = Rect2((_anim_frame % LIRA_FRAME_COUNT) * LIRA_FRAME_SIZE.x, 0, LIRA_FRAME_SIZE.x, LIRA_FRAME_SIZE.y)


func _adapt_layout() -> void:
	var w := get_viewport_rect().size.x
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

# Button Callbacks
# These functions are connected to the respective buttons in the new game scene. They handle user interactions
# This also includes Audio Cues for button actions.

func _on_male_pressed() -> void:
	UiSfxManager.play_confirm()
	_selected_gender = "male"
	_male_button.add_theme_color_override("font_color", Color.YELLOW)
	_female_button.remove_theme_color_override("font_color")
	_gender_label.text = "You will play as Arin. Lira will be your companion."
	_info_card.visible = true
	_confirm_button.disabled = false


func _on_female_pressed() -> void:
	UiSfxManager.play_confirm()
	_selected_gender = "female"
	_female_button.add_theme_color_override("font_color", Color.YELLOW)
	_male_button.remove_theme_color_override("font_color")
	_gender_label.text = "You will play as Lira. Arin will be your companion."
	_info_card.visible = true
	_confirm_button.disabled = false


func _on_confirm_pressed() -> void:
	UiSfxManager.play_confirm()
	PlayerData.setup(PlayerData.player_name, _selected_gender)

	var slot := SaveManager.get_first_empty_slot()
	if slot == -1:
		slot = 1
	SaveManager.save_game(slot)

	get_tree().change_scene_to_file("res://scenes/ui/auto_save_notice.tscn")


func _on_back_pressed() -> void:
	UiSfxManager.play_confirm()
	SceneTransition.change_scene("res://scenes/ui/new_game.tscn")


# Dedicated Hover Audio Cues

func _on_back_button_focus_entered() -> void:
	UiSfxManager.play_hover()

func _on_back_button_mouse_entered() -> void:
	UiSfxManager.play_hover()


func _on_confirm_button_mouse_entered() -> void:
	UiSfxManager.play_hover()


func _on_confirm_button_focus_entered() -> void:
	UiSfxManager.play_hover()


func _on_female_button_mouse_entered() -> void:
	UiSfxManager.play_hover()


func _on_female_button_focus_entered() -> void:
	UiSfxManager.play_hover()


func _on_male_button_mouse_entered() -> void:
	UiSfxManager.play_hover()

func _on_male_button_focus_entered() -> void:
	UiSfxManager.play_hover()
