class_name Controller
extends Node2D


signal input_handled
signal move_vector_changed(move_vector: Vector2)
signal move_vector_changed_normalized(move_vector: Vector2)

@export var move_vector := Vector2.ZERO:
	set(value):
		move_vector = value
		move_vector_changed.emit(move_vector)
		move_vector_changed_normalized.emit(move_vector.normalized())

@export var look_vector := Vector2.ZERO
@export var button_1_pressed := false
@export var button_2_pressed := false


func force_handle_input() -> void:
	pass


func is_action_pressed(action: StringName) -> bool:
	return {
			"button_1": button_1_pressed,
			"button_2": button_2_pressed
	}.get(action, false)
