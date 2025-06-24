extends Node2D

@onready var ghost: ControllableCharacter = $Ghost


func _unhandled_input(event: InputEvent) -> void:
	ghost.controller.force_handle_input()
