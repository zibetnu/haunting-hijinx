extends Controller


@export var deadzone := 0.1


func _unhandled_input(_event: InputEvent) -> void:
	var new_move_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if new_move_vector.length() > deadzone:
		move_vector = new_move_vector

	else:
		move_vector = Vector2.ZERO

	var new_look_vector = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if new_look_vector.length() > deadzone:
		look_vector = new_look_vector

	else:
		look_vector = Vector2.ZERO

	button_1_pressed = Input.is_action_pressed("button_1")
	button_2_pressed = Input.is_action_pressed("button_2")

	input_handled.emit()
