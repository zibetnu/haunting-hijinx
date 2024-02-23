class_name Controller
extends Node2D


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

@export var button_1_pressed := false
@export var button_2_pressed := false


func force_handle_input() -> void:
	pass


func is_action_pressed(action: StringName) -> bool:
	return {
			"button_1": button_1_pressed,
			"button_2": button_2_pressed
	}.get(action, false)
