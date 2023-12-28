extends Node


@export var active := true
@export var flashlight_behavior: Node
@export var controller: Controller:
	set(value):
		if controller and controller.input_handled.is_connected(_on_controller_input_handled):
			controller.input_handled.disconnect(_on_controller_input_handled)

		controller = value
		if controller and not controller.input_handled.is_connected(_on_controller_input_handled):
			controller.input_handled.connect(_on_controller_input_handled)


func _on_controller_input_handled() -> void:
	if not active:
		return

	flashlight_behavior.set("powered", controller.button_1_pressed)
	if not controller.look_vector.is_zero_approx():
		flashlight_behavior.set("target_rotation", controller.look_vector.angle())
