extends Control

const LAGUNA_FACTS := [
	"San Pablo City is known as the 'City of Seven Lakes' for its seven volcanic crater lakes!",
	"Laguna is named after 'Laguna de Bay,' the largest lake in the Philippines!",
	"Pagsanjan, Laguna is world-famous for its majestic waterfalls and rapids!",
	"José Rizal, the national hero, was born in Calamba, Laguna in 1861!",
	"Los Baños is home to UPLB, one of the country's top universities!",
	"Laguna's hot springs are heated by the volcanic activity of Mount Makiling!",
	"Mount Makiling is named after 'Maria Makiling,' a guardian spirit in Filipino folklore!",
	"Paete's woodcarving tradition spans over 400 years — the 'Carving Capital of the Philippines'!",
	"Laguna de Bay supplies freshwater fish like bangus and tilapia to Metro Manila!",
	"Buko pie, a beloved coconut pastry, is a signature delicacy of Los Baños, Laguna!",
	"The first Filipino printing press was established in Pila, Laguna!",
	"Laguna was one of eight provinces that revolted against Spain, shown on the flag's sun rays!",
	"The Laguna Copperplate Inscription (900 AD) is the oldest written document in the Philippines!",
	"Liliw, Laguna is famous for handcrafted tsinelas and footwear shopping!",
	"Nagcarlan Underground Cemetery is the only underground cemetery in the Philippines!",
]

@onready var _margin: MarginContainer = $MarginContainer
@onready var _fun_fact: Label = $MarginContainer/VBoxContainer/Fun_Fact
@onready var _play_button: Button = $MarginContainer/VBoxContainer/Play_Button
@onready var _new_game_warning: Control = $NewGameWarning
@onready var _exit_warning: Control = $ExitWarning


func _ready() -> void:
	_show_random_fact()
	_update_continue_state()
	_adapt_layout()
	resized.connect(_adapt_layout)


func _update_continue_state() -> void:
	var has_saves := SaveManager.has_any_saves()
	_play_button.disabled = not has_saves
	if has_saves:
		_play_button.text = "Continue"
	else:
		_play_button.text = "Continue"
		_play_button.tooltip_text = "No save data found"


func _show_random_fact() -> void:
	_fun_fact.text = LAGUNA_FACTS[randi() % LAGUNA_FACTS.size()]


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


func _on_quit_button_pressed() -> void:
	_exit_warning.visible = true


func _on_exit_close() -> void:
	_exit_warning.visible = false


func _on_exit_confirmed() -> void:
	get_tree().quit()


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/game_settings.tscn")

func _on_new_game_pressed() -> void:
	if SaveManager.has_any_saves():
		_new_game_warning.visible = true
	else:
		get_tree().change_scene_to_file("res://scenes/ui/new_game.tscn")


func _on_new_game_close() -> void:
	_new_game_warning.visible = false


func _on_new_game_confirmed() -> void:
	for i in range(1, SaveManager.MAX_SLOTS + 1):
		SaveManager.delete_save(i)
	get_tree().change_scene_to_file("res://scenes/ui/new_game.tscn")


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/save_slots.tscn")
