extends Node

@onready var hover_player = $Hover
@onready var confirm_sel = $Confirm


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# These functions are used to play sound effects for UI interactions. The hover sound is played when the user hovers over a button, and the confirm sound is played when the user clicks a button.
func play_hover() -> void:
	hover_player.pitch_scale = randf_range(0.9, 1.1)
	hover_player.play()

func play_confirm() -> void:
	confirm_sel.pitch_scale = randf_range(0.9, 1.1)
	confirm_sel.play()