extends StateComponent
## Sends controller events upon state entry so that held controller inputs will
## trigger transitions.


@export var controller: Controller
@export var state_chart: StateChart

@export_group("Ignore", "ignore")
@export var ignore_move_vector := false
@export var ignore_button_1 := false
@export var ignore_button_2 := false


func _send_move_vector_event() -> void:
	if controller.move_vector.is_zero_approx():
		state_chart.send_event("move_stopped")

	else:
		state_chart.send_event("move_started")


func _send_button_1_event() -> void:
	if controller.button_1:
		state_chart.send_event("button_1_pressed")

	else:
		state_chart.send_event("button_1_released")


func _send_button_2_event() -> void:
	if controller.button_2:
		state_chart.send_event("button_2_pressed")

	else:
		state_chart.send_event("button_2_released")


func _on_state_entered() -> void:
	if not controller:
		return

	if not state_chart:
		return

	if not ignore_move_vector:
		_send_move_vector_event()

	if not ignore_button_1:
		_send_button_1_event()

	if not ignore_button_2:
		_send_button_2_event()
