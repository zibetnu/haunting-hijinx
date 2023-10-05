extends Controller


@export var controller_1: Controller
@export var controller_2: Controller


func _ready() -> void:
	controller_1.input_handled.connect(_on_controller_input_handled)
	controller_2.input_handled.connect(_on_controller_input_handled)


func _on_controller_input_handled() -> void:
	if controller_1.move_vector:
		move_vector = controller_1.move_vector

	else:
		move_vector = controller_2.move_vector

	if controller_1.look_vector:
		look_vector = controller_1.look_vector

	else:
		look_vector = controller_2.look_vector

	button_1_pressed = controller_1.button_1_pressed or controller_2.button_1_pressed
	button_2_pressed = controller_1.button_2_pressed or controller_2.button_2_pressed
	input_handled.emit()
