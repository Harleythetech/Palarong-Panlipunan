extends Control

@onready var _margin: MarginContainer = $MarginContainer
@onready var _slots_container: VBoxContainer = $MarginContainer/Layout/ContentPanel/ContentMargin/VBoxContainer/SlotsContainer


func _ready() -> void:
	_populate_slots()
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


func _populate_slots() -> void:
	for child in _slots_container.get_children():
		child.queue_free()

	for i in range(1, SaveManager.MAX_SLOTS + 1):
		var info := SaveManager.get_slot_info(i)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 56)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		if info.get("exists", false):
			var gender_icon := "♂" if info.gender == "male" else "♀"
			btn.text = "Slot %d  |  %s %s  |  Ch.%d  |  %s" % [
				i, gender_icon, info.player_name, info.chapter, info.timestamp
			]
			var slot := i
			btn.pressed.connect(_on_slot_pressed.bind(slot))
		else:
			btn.text = "Slot %d  —  Empty" % i
			btn.disabled = true

		_slots_container.add_child(btn)


func _on_slot_pressed(slot: int) -> void:
	if SaveManager.load_game(slot):
		SceneTransition.change_scene("res://scenes/ui/tutorial_placeholder.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
