class_name SyncedController
extends Controller

# Use the first byte of _input_bits to store booleans.
enum BitFlags {
	BUTTON_1 = 1 << 0,
	BUTTON_2 = 1 << 1,
}

# Use 3 bytes each to store the angle and length of the move and look vectors.
const ANGLE_MULTIPLIER = (2.0 ** 16 - 1) / 360
const LENGTH_MULTIPLIER = 2 ** 8 - 1
const LOOK_OFFSET = 8
const MOVE_OFFSET = 32
const VECTOR_MASK = 0xff_ff_ff

@export var controller: Controller
@export var input_authority := 1:
	set(value):
		input_authority = value
		$InputSynchronizer.set_multiplayer_authority(value)

var _input_bits := 0:
	set(value):
		_input_bits = value
		button_1 = bool(_input_bits & BitFlags.BUTTON_1)
		button_2 = bool(_input_bits & BitFlags.BUTTON_2)
		look_vector = _unserialize_vector(
				(_input_bits & (VECTOR_MASK << LOOK_OFFSET)) >> LOOK_OFFSET
		)
		move_vector = _unserialize_vector(
				(_input_bits & (VECTOR_MASK << MOVE_OFFSET)) >> MOVE_OFFSET
		)
		input_handled.emit()


func _ready() -> void:
	controller.input_handled.connect(_on_controller_input_handled)


func force_handle_input() -> void:
	if controller:
		controller.force_handle_input()


func set_input_authority(id: int) -> void:
	input_authority = id


func _serialize_vector(vector: Vector2) -> int:
	var serialized_angle := roundi(
			rad_to_deg(fposmod(vector.angle(), TAU) * ANGLE_MULTIPLIER)
	)
	var serialized_length := roundi(vector.length() * LENGTH_MULTIPLIER)

	var serialized_vector := 0
	serialized_vector |= serialized_angle
	serialized_vector |= serialized_length << 16

	return serialized_vector


func _unserialize_vector(serialized_vector: int) -> Vector2:
	var unserialized_degrees: float = (
			float(serialized_vector & 0xff_ff) / ANGLE_MULTIPLIER
	)
	if unserialized_degrees > 180:
		unserialized_degrees -= 360

	var unserialized_length := (
			float((serialized_vector & 0xff_00_00) >> 16) / LENGTH_MULTIPLIER
	)
	var unserialized_vector := Vector2(unserialized_length, 0)

	return unserialized_vector.rotated(deg_to_rad(unserialized_degrees))


func _on_controller_input_handled() -> void:
	if not $InputSynchronizer.is_multiplayer_authority():
		return

	var new_input_bits := 0
	if controller.button_1:
		new_input_bits |= BitFlags.BUTTON_1

	if controller.button_2:
		new_input_bits |= BitFlags.BUTTON_2

	new_input_bits |= _serialize_vector(controller.look_vector) << LOOK_OFFSET
	new_input_bits |= _serialize_vector(controller.move_vector) << MOVE_OFFSET
	_input_bits = new_input_bits
