extends Controller


func _on_timer_timeout() -> void:
	move_vector = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	look_vector = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	button_1 = not button_1
	button_2 = not button_2
	input_handled.emit()
