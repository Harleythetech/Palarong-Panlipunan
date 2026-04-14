extends CanvasLayer

@onready var _color_rect: ColorRect = $ColorRect
const FADE_DURATION := 0.3


func _ready() -> void:
	layer = 100
	_color_rect.color = Color(0, 0, 0, 0)
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func change_scene(path: String) -> void:
	_color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var fade_out := create_tween()
	fade_out.tween_property(_color_rect, "color:a", 1.0, FADE_DURATION)
	fade_out.tween_callback(_do_change.bind(path))


func _do_change(path: String) -> void:
	get_tree().change_scene_to_file(path)
	var fade_in := create_tween()
	fade_in.tween_property(_color_rect, "color:a", 0.0, FADE_DURATION)
	fade_in.tween_callback(func(): _color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE)
