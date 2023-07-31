extends Controller


func _process(_delta: float) -> void:
	move_vector = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	look_vector = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	button_1_pressed = not button_1_pressed
	button_2_pressed = not button_2_pressed
