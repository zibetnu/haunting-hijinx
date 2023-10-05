extends Controller


@export var controller: Controller
@export var button_release_time := 0.1


func _ready() -> void:
	controller.input_handled.connect(_on_controller_input_handled)


func _on_controller_input_handled() -> void:
	move_vector = controller.move_vector
	look_vector = controller.look_vector
	_handle_button("button_1_pressed", $Button1ReleaseTimer)
	_handle_button("button_2_pressed", $Button2ReleaseTimer)


func _handle_button(button_name: String, timer: Timer) -> void:
	var button_states := [controller.get(button_name), get(button_name)]
	match button_states:
		[true, false]:
			set(button_name, true)

		[false, true]:
			if timer.is_stopped():
				timer.start(button_release_time)


func _on_button_1_release_timer_timeout() -> void:
	if controller.button_1_pressed:
		return

	button_1_pressed = false


func _on_button_2_release_timer_timeout() -> void:
	if controller.button_2_pressed:
		return

	button_2_pressed = false
