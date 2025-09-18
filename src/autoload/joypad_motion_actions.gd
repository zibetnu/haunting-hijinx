extends Node

var ignore_until_next_frame := false:
	set = set_ignore_until_next_frame
var quadrants: Array[Quadrant] = [
	Quadrant.new(&"ui_left", PI),
	Quadrant.new(&"ui_right", 0.0),
	Quadrant.new( &"ui_up", 3 * PI / 2.0),
	Quadrant.new(&"ui_down", PI / 2.0),
]


func _ready() -> void:
	set_process(ignore_until_next_frame)


func _process(_delta: float) -> void:
	ignore_until_next_frame = false


func _input(event: InputEvent) -> void:
	if event is not InputEventJoypadMotion:
		return

	if ignore_until_next_frame:
		return

	var vector: Vector2 = Input.get_vector(
			&"joypad_ui_left",
			&"joypad_ui_right",
			&"joypad_ui_up",
			&"joypad_ui_down",
	)
	if vector.length() < 0.5:
		for quadrant in quadrants:
			quadrant.pressed = false

		return

	for quadrant in quadrants:
		quadrant.update_from_angle(vector.angle())

	ignore_until_next_frame = true


func set_ignore_until_next_frame(value: bool) -> void:
	ignore_until_next_frame = value
	set_process(ignore_until_next_frame)


class Quadrant extends RefCounted:
	var action: StringName
	var arc: float = PI / 3.0
	var center: float
	var pressed := false:
		set = set_pressed

	@warning_ignore("shadowed_variable")
	func _init(action: StringName, center: float) -> void:
		self.center = center
		self.action = action

	func update_from_angle(angle: float) -> void:
		pressed = abs(angle_difference(center, angle)) < arc / 2.0

	func set_pressed(value: bool) -> void:
		var was_pressed: bool = pressed
		pressed = value
		match [was_pressed, pressed]:
			[false, true]:
				_send_event(true)

			[true, false]:
				_send_event(false)

	func _send_event(event_pressed: bool) -> void:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = event_pressed
		Input.parse_input_event(event)
