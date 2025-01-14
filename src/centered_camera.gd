class_name CenteredCamera
extends Camera2D

@onready var _window: Window = get_window()


func _ready() -> void:
	_window.size_changed.connect(center)
	center()


## Changes [member Camera2D.offset] to make the area bounded by the camera's
## limits appear centered in a window that is larger than those limits.
func center() -> void:
	var content_scale_size: Vector2i = _window.content_scale_size
	var limit_size := Vector2i(
			limit_right - limit_left,
			limit_bottom - limit_top
	)
	var new_offset := Vector2.ZERO
	if content_scale_size.x > limit_size.x:
		new_offset.x = float(content_scale_size.x - limit_size.x) / 2

	if content_scale_size.y > limit_size.y:
		new_offset.y = float(limit_size.y - content_scale_size.y) / 2

	offset = new_offset
