extends Controller


@export var controller_1: Controller
@export var controller_2: Controller


func _process(_delta: float) -> void:
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
