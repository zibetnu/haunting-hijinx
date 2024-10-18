extends Controller


func _process(_delta: float) -> void:
	_look_at_mouse_if_visible()
	if _is_mouse_visible():
		input_handled.emit()


func _unhandled_input(_event: InputEvent) -> void:
	move_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_look_at_mouse_if_visible()
	button_1 = Input.is_action_pressed("button_1")
	button_2 = Input.is_action_pressed("button_2")

	input_handled.emit()


func force_handle_input() -> void:
	move_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_look_at_mouse_if_visible()
	button_1 = Input.is_action_pressed("button_1")
	button_2 = Input.is_action_pressed("button_2")
	input_handled.emit()


func _is_mouse_visible() -> bool:
	return not Input.get_mouse_mode() in [
			Input.MOUSE_MODE_CONFINED_HIDDEN,
			Input.MOUSE_MODE_HIDDEN
	]


func _look_at_mouse_if_visible() -> void:
	if not _is_mouse_visible():
		look_vector = Vector2.ZERO
		return

	look_vector = Vector2.from_angle(
			global_position.angle_to_point(get_global_mouse_position())
	)
