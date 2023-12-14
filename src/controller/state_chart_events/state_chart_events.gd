extends Controller


@export var controller: Controller
@export var state_chart: StateChart


func _ready() -> void:
	if not controller:
		push_error("Controller not set.")

	if not state_chart:
		push_error("State chart not set.")

	controller.input_handled.connect(_on_controller_input_handled)


func _on_controller_input_handled() -> void:
	var move_vector_state: Array[bool] = [
		move_vector.is_equal_approx(controller.move_vector),
		move_vector.is_zero_approx(),
		controller.move_vector.is_zero_approx()
	]
	match move_vector_state:
		[false, false, true]:
			state_chart.send_event("idle")

		[false, true, false]:
			state_chart.send_event("move")

	move_vector = controller.move_vector
	look_vector = controller.look_vector
	button_1_pressed = controller.button_1_pressed
	button_2_pressed = controller.button_2_pressed
	input_handled.emit()
