extends Controller


@export var controller: Controller
@export var x_deadzone := 0.03
@export var y_deadzone := 0.03


func _ready() -> void:
	controller.input_handled.connect(_on_controller_input_handled)


func remove_axis_drift(vector: Vector2) -> Vector2:
	if abs(vector.x) < x_deadzone:
		vector.x = 0

	if abs(vector.y) < y_deadzone:
		vector.y = 0

	return vector


func _on_controller_input_handled() -> void:
	move_vector = remove_axis_drift(controller.move_vector)
	look_vector = remove_axis_drift(controller.look_vector)
	button_1 = controller.button_1
	button_2 = controller.button_2
	input_handled.emit()
