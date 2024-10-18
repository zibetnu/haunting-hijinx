extends Node


const ACTIVE_MODE = Input.MOUSE_MODE_CONFINED
const INACTIVE_MODE = Input.MOUSE_MODE_HIDDEN


func _ready() -> void:
	Input.set_mouse_mode(INACTIVE_MODE)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		Input.set_mouse_mode(ACTIVE_MODE)

	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		Input.set_mouse_mode(INACTIVE_MODE)
