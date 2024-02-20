extends Node


@export var controller: Controller:
	set(value):
		if controller and controller.input_handled.is_connected(_on_controller_input_handled):
			controller.input_handled.disconnect(_on_controller_input_handled)

		controller = value
		if controller and not controller.input_handled.is_connected(_on_controller_input_handled):
			controller.input_handled.connect(_on_controller_input_handled)

@export var state_chart: StateChart


func _on_controller_input_handled() -> void:
	if not state_chart:
		return

	state_chart.set_expression_property("move_vector", controller.move_vector)
	state_chart.set_expression_property("look_vector", controller.look_vector)
	state_chart.set_expression_property("button_1_pressed", controller.button_1)
	state_chart.set_expression_property("button_2_pressed", controller.button_2)
