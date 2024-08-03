extends Controller


## The minimum number of milliseconds that must elapse between two
## [method Node._process] calls before the controller calls
## [method Controller.force_handle_input].
const PAUSED_MSEC_THRESHOLD = 100

@export var controller: Controller

@onready var _last_process_ticks_msec: int = Time.get_ticks_msec()


func _ready() -> void:
	controller.input_handled.connect(_on_controller_input_handled)


func _process(_delta: float) -> void:
	var process_ticks_msec: int = Time.get_ticks_msec()
	if process_ticks_msec - _last_process_ticks_msec >= PAUSED_MSEC_THRESHOLD:
		controller.force_handle_input()

	_last_process_ticks_msec = process_ticks_msec


func force_handle_input() -> void:
	controller.force_handle_input()


func _on_controller_input_handled() -> void:
	move_vector = controller.move_vector
	look_vector = controller.look_vector
	button_1 = controller.button_1
	button_2 = controller.button_2
	input_handled.emit()
