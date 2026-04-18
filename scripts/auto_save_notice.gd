extends Control

@onready var _icon: Label = $Content/IconLabel
@onready var _continue_button: Button = $BottomMargin/ContinueButton
@onready var _timer: Timer = $Timer


func _ready() -> void:
	modulate = Color(1, 1, 1, 0)
	_continue_button.visible = false

	# Slowly fade music out
	var fade_out := create_tween()
	fade_out.tween_property(GameBgm, "volume_db", -80.0, 3.0)
	# Fade in from black
	var fade_in := create_tween()
	fade_in.tween_property(self , "modulate:a", 1.0, 0.6)
	fade_in.tween_callback(_start_glow)

	# Show continue button after delay
	_timer.wait_time = 3.0
	_timer.one_shot = true
	_timer.timeout.connect(_on_timeout)
	_timer.start()

func _start_glow() -> void:
	var glow := create_tween().set_loops()
	glow.tween_property(_icon, "modulate:a", 0.3, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	glow.tween_property(_icon, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_timeout() -> void:
	_continue_button.visible = true
	_continue_button.modulate = Color(1, 1, 1, 0)
	var btn_fade := create_tween()
	btn_fade.tween_property(_continue_button, "modulate:a", 1.0, 0.4)


func _on_continue_pressed() -> void:
	UiSfxManager.play_confirm()
	get_tree().change_scene_to_file("res://scenes/ui/tutorial_placeholder.tscn")


func _on_continue_button_mouse_entered() -> void:
	UiSfxManager.play_hover()

func _on_continue_button_focus_entered() -> void:
	UiSfxManager.play_hover()
