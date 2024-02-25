class_name Controller
extends Node2D


signal button_1_changed(button_1: bool)
signal button_1_pressed
signal button_1_released
signal button_2_changed(button_1: bool)
signal button_2_pressed
signal button_2_released
signal input_handled
signal move_started
signal move_stopped
signal move_vector_changed(move_vector: Vector2)
signal look_vector_changed(look_vector: Vector2)

@export var move_vector := Vector2.ZERO:
	set(value):
		value = value.normalized()
		var vector_state: Array[bool] = [
			move_vector.is_equal_approx(value),
			move_vector.is_zero_approx(),
			value.is_zero_approx(),
		]
		move_vector = value
		move_vector_changed.emit(move_vector)
		match vector_state:
			[false, false, true]:
				move_stopped.emit()

			[false, true, false]:
				move_started.emit()

@export var look_vector := Vector2.ZERO:
	set(value):
		look_vector = value.normalized()
		look_vector_changed.emit(look_vector)

@export var button_1 := false:
	set(value):
		var button_state: Array[bool] = [button_1, value]
		button_1 = value
		button_1_changed.emit(button_1)
		match button_state:
			[true, false]:
				button_1_released.emit()

			[false, true]:
				button_1_pressed.emit()

@export var button_2 := false:
	set(value):
		var button_state: Array[bool] = [button_2, value]
		button_2 = value
		button_2_changed.emit(button_2)
		match button_state:
			[true, false]:
				button_2_released.emit()

			[false, true]:
				button_2_pressed.emit()


func force_emit_move_vector_signals() -> void:
	move_vector_changed.emit(move_vector)
	if move_vector.is_zero_approx():
		move_stopped.emit()

	else:
		move_started.emit()


func force_emit_look_vector_signals() -> void:
	look_vector_changed.emit(look_vector)


func force_emit_button_1_signals() -> void:
	button_1_changed.emit(button_1)
	if button_1:
		button_1_pressed.emit()

	else:
		button_1_released.emit()


func force_emit_button_2_signals() -> void:
	if button_2:
		button_2_pressed.emit()

	else:
		button_2_released.emit()


func force_handle_input() -> void:
	pass


func is_action_pressed(action: StringName) -> bool:
	return {
			"button_1": button_1,
			"button_2": button_2
	}.get(action, false)
