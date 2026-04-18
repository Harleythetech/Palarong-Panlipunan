extends Control

@onready var _margin: MarginContainer = $MarginContainer
@onready var _name_input: LineEdit = $MarginContainer/Layout/ContentPanel/ContentMargin/VBoxContainer/NameSection/NameInput
@onready var _next_button: Button = $MarginContainer/Layout/ContentPanel/ContentMargin/VBoxContainer/NextButton


func _ready() -> void:
	_next_button.disabled = true
	_name_input.text_changed.connect(_on_name_changed)
	# Restore name if going back from gender screen
	if PlayerData.player_name != "":
		_name_input.text = PlayerData.player_name
		_next_button.disabled = false
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


func _on_name_changed(_new_text: String) -> void:
	_next_button.disabled = _name_input.text.strip_edges().length() == 0


# Button Callbacks
# These functions are connected to the respective buttons in the new game scene. They handle user interactions
# This also includes Audio Cues for button actions.

func _on_next_pressed() -> void:
	UiSfxManager.play_confirm()
	PlayerData.player_name = _name_input.text.strip_edges()
	SceneTransition.change_scene("res://scenes/ui/select_gender.tscn")


func _on_back_pressed() -> void:
	UiSfxManager.play_confirm()
	PlayerData.reset()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


# Dedicated Hover Audio Cues

func _on_back_button_focus_entered() -> void:
	UiSfxManager.play_hover()


func _on_back_button_mouse_entered() -> void:
	UiSfxManager.play_hover()


func _on_next_button_mouse_entered() -> void:
	UiSfxManager.play_hover()

func _on_next_button_focus_entered() -> void:
	UiSfxManager.play_hover()
