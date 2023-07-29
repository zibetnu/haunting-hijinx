extends Controller


var _mouse_active := false


func _process(_delta: float) -> void:
	move_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if _mouse_active:
		look_vector = Vector2.from_angle(
				global_position.angle_to_point(get_global_mouse_position())
		)

	else:
		look_vector = Vector2.ZERO

	button_1_pressed = Input.is_action_pressed("button_1")
	button_2_pressed = Input.is_action_pressed("button_2")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_active = true
		$Timer.start()


func _on_timer_timeout() -> void:
	_mouse_active = false
