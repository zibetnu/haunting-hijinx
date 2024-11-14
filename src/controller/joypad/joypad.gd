extends Controller


func force_handle_input() -> void:
	_unhandled_input(null)


func _unhandled_input(_event: InputEvent) -> void:
	move_vector = Input.get_vector(
			"move_left", "move_right", "move_up", "move_down"
	)
	look_vector = Input.get_vector(
			"look_left", "look_right", "look_up", "look_down"
	)
	button_1 = Input.is_action_pressed("button_1")
	button_2 = Input.is_action_pressed("button_2")
	input_handled.emit()
