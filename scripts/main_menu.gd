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
	GameBgm.volume_db = 0.0
	_show_random_fact()
	_update_continue_state()
	_adapt_layout()
	resized.connect(_adapt_layout)

# This function checks if there are any existing save files using the SaveManager. If there are saves, it enables the "Continue" button and sets its text to "Continue". If there are no saves, it disables the button and updates the tooltip to inform the user that no save data was found. This function is called when the main menu scene is ready to ensure the play button reflects the current save state.

func _update_continue_state() -> void:
	var has_saves := SaveManager.has_any_saves()
	_play_button.disabled = not has_saves
	if has_saves:
		_play_button.text = "Continue"
	else:
		_play_button.text = "Continue"
		_play_button.tooltip_text = "No save data found"

# This function randomly selects a fun fact about Laguna from the LAGUNA_FACTS array and displays it in the _fun_fact label on the main menu. It uses the randi() function to generate a random index and the modulo operator to ensure it stays within the bounds of the array.

func _show_random_fact() -> void:
	_fun_fact.text = LAGUNA_FACTS[randi() % LAGUNA_FACTS.size()]

# This function adjusts the layout of the main menu based on the width of the viewport. It calculates a margin value that increases as the width increases, providing more spacing on larger screens and ensuring a comfortable layout on smaller screens. The margin values are applied to all sides of the MarginContainer to maintain consistent spacing around the content.

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


##############################
# Button Callbacks
# These functions are connected to the respective buttons in the main menu. They handle user interactions such as starting a new game, continuing from a save, opening the settings menu, and quitting the game. Each function performs the necessary checks and transitions to the appropriate scenes or displays warnings as needed.
##############################


# Function Exit: When the user clicks the quit button, it shows a confirmation dialog. If the user confirms, the game will quit. If they cancel, the dialog will close without exiting the game.
func _on_quit_button_pressed() -> void:
	UiSfxManager.play_confirm()
	_exit_warning.visible = true


func _on_exit_close() -> void:
	UiSfxManager.play_confirm()
	_exit_warning.visible = false


func _on_exit_confirmed() -> void:
	UiSfxManager.play_confirm()
	get_tree().quit()


# Function Options: When the user clicks the options button, it transitions to the game settings scene where they can adjust various settings for the game.
func _on_options_button_pressed() -> void:
	UiSfxManager.play_confirm()
	get_tree().change_scene_to_file("res://scenes/ui/game_settings.tscn")


# Function New Game: When the user clicks the new game button, it checks if there are any existing saves. If there are saves, it shows a warning dialog to confirm if they want to start a new game and overwrite their existing saves. If they confirm, it deletes all saves and transitions to the new game scene. If they cancel, it simply closes the warning dialog.
func _on_new_game_pressed() -> void:
	UiSfxManager.play_confirm()
	if SaveManager.has_any_saves():
		_new_game_warning.visible = true
	else:
		get_tree().change_scene_to_file("res://scenes/ui/new_game.tscn")


func _on_new_game_close() -> void:
	UiSfxManager.play_confirm()
	_new_game_warning.visible = false


func _on_new_game_confirmed() -> void:
	UiSfxManager.play_confirm()
	for i in range(1, SaveManager.MAX_SLOTS + 1):
		SaveManager.delete_save(i)
	get_tree().change_scene_to_file("res://scenes/ui/new_game.tscn")


# Function Continue: When the user clicks the continue button, it transitions to the save slots scene where they can select which save file to load and continue their game.
func _on_play_button_pressed() -> void:
	UiSfxManager.play_confirm()
	get_tree().change_scene_to_file("res://scenes/ui/save_slots.tscn")


##############################
# Hover Functions
# These functions are connected to the mouse entered signals of the buttons. They play a hover sound effect using the UiSfxManager when the user hovers over the respective buttons, providing audio feedback for their interactions.

# For further configuration of sfx Visit ui_sfx_manager.gd and ui_sfx_manager.tscn
##############################


# Function Play Hover
func _on_play_button_mouse_entered() -> void:
	UiSfxManager.play_hover()


func _on_play_button_focus_entered() -> void:
	UiSfxManager.play_hover()

# Function New Game Hover
func _on_new_game_focus_entered() -> void:
	UiSfxManager.play_hover()


func _on_new_game_mouse_entered() -> void:
	UiSfxManager.play_hover()

# Function Options Hover
func _on_options_button_focus_entered() -> void:
	UiSfxManager.play_hover()


func _on_options_button_mouse_entered() -> void:
	UiSfxManager.play_hover()

# Function Quit Hover
func _on_quit_button_focus_entered() -> void:
	UiSfxManager.play_hover()


func _on_quit_button_mouse_entered() -> void:
	UiSfxManager.play_hover()

# Function Cancel Hover (for warning dialogs)
func _on_cancel_button_focus_entered() -> void:
	UiSfxManager.play_hover()

func _on_cancel_button_mouse_entered() -> void:
	UiSfxManager.play_hover()

# Function Confirm Button Hover (for warning dialogs)
func _on_confirm_button_focus_entered() -> void:
	UiSfxManager.play_hover()

func _on_confirm_button_mouse_entered() -> void:
	UiSfxManager.play_hover()
