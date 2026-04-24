extends Control

var _selected_gender: String = ""

@onready var _margin: MarginContainer = $MarginContainer
@onready var _male_button: Button = $MarginContainer/Layout/ContentPanel/ContentMargin/VBoxContainer/GenderSection/GenderButtons/MaleButton
@onready var _female_button: Button = $MarginContainer/Layout/ContentPanel/ContentMargin/VBoxContainer/GenderSection/GenderButtons/FemaleButton
@onready var _confirm_button: Button = $MarginContainer/Layout/ContentPanel/ContentMargin/VBoxContainer/ConfirmButton
@onready var _gender_label: Label = $MarginContainer/Layout/InfoCard/MarginContainer/GenderInfo
@onready var _name_display: Label = $MarginContainer/Layout/ContentPanel/ContentMargin/VBoxContainer/NameDisplay
@onready var _info_card: PanelContainer = $MarginContainer/Layout/InfoCard


func _ready() -> void:
	_confirm_button.disabled = true
	_name_display.text = "Playing as: %s" % PlayerData.player_name
	_adapt_layout()
	resized.connect(_adapt_layout)


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
	_gender_label.text = "You selected: Boy"
	_info_card.visible = true
	_confirm_button.disabled = false


func _on_female_pressed() -> void:
	UiSfxManager.play_confirm()
	_selected_gender = "female"
	_female_button.add_theme_color_override("font_color", Color.YELLOW)
	_male_button.remove_theme_color_override("font_color")
	_gender_label.text = "You selected: Girl"
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
