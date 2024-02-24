extends Controller


var _mouse_active := false


func _unhandled_input(event: InputEvent) -> void:
	move_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if event is InputEventMouseMotion:
		_mouse_active = true
		$Timer.start()

	if _mouse_active:
		look_vector = Vector2.from_angle(
				global_position.angle_to_point(get_global_mouse_position())
		)

	else:
		look_vector = Vector2.ZERO

	button_1 = Input.is_action_pressed("button_1")
	button_2 = Input.is_action_pressed("button_2")

	input_handled.emit()


func force_handle_input() -> void:
	move_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if _mouse_active:
		look_vector = Vector2.from_angle(
				global_position.angle_to_point(get_global_mouse_position())
		)

	else:
		look_vector = Vector2.ZERO

	button_1 = Input.is_action_pressed("button_1")
	button_2 = Input.is_action_pressed("button_2")
	input_handled.emit()


func _on_timer_timeout() -> void:
	_mouse_active = false
