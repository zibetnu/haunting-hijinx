class_name Controller
extends Node2D


@export var move_vector := Vector2.ZERO
@export var look_vector := Vector2.ZERO
@export var button_1_pressed := false
@export var button_2_pressed := false


func is_action_pressed(action: StringName) -> bool:
	return {
			"button_1": button_1_pressed,
			"button_2": button_2_pressed
	}.get(action, false)
