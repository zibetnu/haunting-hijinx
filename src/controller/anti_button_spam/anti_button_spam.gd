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
			button_1 != controller.button_1
			and _button_1_changes < max_changes_per_second
	):
		button_1 = controller.button_1
		_button_1_changes += 1

	if (
			button_2 != controller.button_2
			and _button_2_changes < max_changes_per_second
	):
		button_2 = controller.button_2
		_button_2_changes += 1

	input_handled.emit()


func _on_reset_timer_timeout() -> void:
	_button_1_changes = 0
	_button_2_changes = 0
