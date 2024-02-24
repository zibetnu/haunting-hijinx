class_name Controller
extends Node2D


signal button_1_changed(button_1: bool)
signal button_2_changed(button_1: bool)
signal input_handled
signal move_vector_changed(move_vector: Vector2)
signal look_vector_changed(look_vector: Vector2)


@export var move_vector := Vector2.ZERO:
	set(value):
		move_vector = value.normalized()
		move_vector_changed.emit(move_vector)

@export var look_vector := Vector2.ZERO:
	set(value):
		look_vector = value.normalized()
		look_vector_changed.emit(look_vector)

@export var button_1 := false:
	set(value):
		button_1 = value
		button_1_changed.emit(button_1)

@export var button_2 := false:
	set(value):
		button_2 = value
		button_2_changed.emit(button_2)


func force_handle_input() -> void:
	pass


func is_action_pressed(action: StringName) -> bool:
	return {
			"button_1": button_1,
			"button_2": button_2
	}.get(action, false)
