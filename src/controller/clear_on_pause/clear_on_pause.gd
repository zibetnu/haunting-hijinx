extends Controller


@export var controller: Controller


func _ready() -> void:
	controller.input_handled.connect(_on_controller_input_handled)


func _on_controller_input_handled() -> void:
	move_vector = controller.move_vector
	look_vector = controller.look_vector
	button_1_pressed = controller.button_1_pressed
	button_2_pressed = controller.button_2_pressed
	input_handled.emit()


func _on_set_pause(value: bool) -> void:
	if not value:
		return

	move_vector = Vector2.ZERO
	look_vector = Vector2.ZERO
	button_1_pressed = false
	button_2_pressed = false
