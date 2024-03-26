extends Controller


@export var controller: Controller


func _ready() -> void:
	controller.input_handled.connect(_on_controller_input_handled)


func force_handle_input() -> void:
	controller.force_handle_input()


func _on_controller_input_handled() -> void:
	move_vector = controller.move_vector
	look_vector = controller.look_vector
	button_1 = controller.button_1
	button_2 = controller.button_2
	input_handled.emit()


func _on_set_pause(value: bool) -> void:
	if not value:
		controller.force_handle_input()
