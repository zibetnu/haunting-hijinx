extends Node

const ACTIVE_MODE = Input.MOUSE_MODE_VISIBLE
const INACTIVE_MODE = Input.MOUSE_MODE_HIDDEN


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	Input.set_mouse_mode(INACTIVE_MODE)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		Input.set_mouse_mode(ACTIVE_MODE)

	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		Input.set_mouse_mode(INACTIVE_MODE)


# Ensures that MouseHider works in any sub-windows.
func _on_node_added(node: Node) -> void:
	var window := node as Window
	if window == null:
		return

	window.window_input.connect(_input)
