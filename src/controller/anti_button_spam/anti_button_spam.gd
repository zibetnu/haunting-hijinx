extends Controller


@export var controller: Controller
@export var max_changes_per_second := 8

var _button_1_changes := 0
var _button_2_changes := 0


func _ready() -> void:
	controller.input_handled.connect(_on_controller_input_handled)


func force_handle_input() -> void:
	controller.force_handle_input()


func _on_controller_input_handled() -> void:
	move_vector = controller.move_vector
	look_vector = controller.look_vector
	if (
			button_1_pressed != controller.button_1_pressed
			and _button_1_changes < max_changes_per_second
	):
		button_1_pressed = controller.button_1_pressed
		_button_1_changes += 1

	if (
			button_2_pressed != controller.button_2_pressed
			and _button_2_changes < max_changes_per_second
	):
		button_2_pressed = controller.button_2_pressed
		_button_2_changes += 1

	input_handled.emit()


func _on_reset_timer_timeout() -> void:
	_button_1_changes = 0
	_button_2_changes = 0
