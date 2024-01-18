extends Node


@export var controller: Controller:
	set(value):
		if controller and controller.input_handled.is_connected(_on_controller_input_handled):
			controller.input_handled.disconnect(_on_controller_input_handled)

		controller = value
		if controller and not controller.input_handled.is_connected(_on_controller_input_handled):
			controller.input_handled.connect(_on_controller_input_handled)

@export var state_chart: StateChart

var _previous_move_vector := Vector2.ZERO
var _previous_look_vector := Vector2.ZERO
var _previous_button_1_pressed := false
var _previous_button_2_pressed := false


func _send_event(event: StringName) -> void:
		if state_chart:
			state_chart.send_event(event)


func _on_controller_input_handled() -> void:
	var move_vector_state: Array[bool] = [
		_previous_move_vector.is_equal_approx(controller.move_vector),
		_previous_move_vector.is_zero_approx(),
		controller.move_vector.is_zero_approx(),
	]
	match move_vector_state:
		[false, false, true]:
			_send_event("move_stopped")

		[false, true, false]:
			_send_event("move_started")

	var button_1_state: Array[bool] = [
		_previous_button_1_pressed == controller.button_1_pressed,
		controller.button_1_pressed
	]
	match button_1_state:
		[false, false]:
			_send_event("button_1_released")

		[false, true]:
			_send_event("button_1_pressed")

	var button_2_state: Array[bool] = [
		_previous_button_2_pressed == controller.button_2_pressed,
		controller.button_2_pressed
	]
	match button_2_state:
		[false, false]:
			_send_event("button_2_released")

		[false, true]:
			_send_event("button_2_pressed")

	_previous_move_vector = controller.move_vector
	_previous_look_vector = controller.look_vector
	_previous_button_1_pressed = controller.button_1_pressed
	_previous_button_2_pressed = controller.button_2_pressed
