class_name Player
extends CharacterBody2D


signal died
signal peer_id_changed(id: int)
signal revived


const AXIS_BITS = 32  # The x and y axis get 32 bits each when serialized.
# Multiplying the axis value by AXIS_MULTIPLIER preserves some of the decimal
# places at the cost of having a lower max value.
const AXIS_MULTIPLIER = (2.0**32 - 1) / MAX_AXIS_VALUE
const AXIS_MASK = 0xff_ff_ff_ff
const MAX_AXIS_VALUE = 6400

@export var controller: Controller
@export var costume: Costume
@export var health_time := 10
@export var modifier_manager: ModifierManager
@export var move_speed := 74
@export var peer_id := 1:
	set(value):
		peer_id = value
		if _is_ready:
			$Camera2D.enabled = value == multiplayer.get_unique_id()

		if "peer_id" in controller:
			controller.peer_id = value

		peer_id_changed.emit(value)

@export var state_machine: StateMachine

var camera_limits := Vector2(MAX_AXIS_VALUE, MAX_AXIS_VALUE):
	set(value):
		camera_limits = value
		$Camera2D.limit_right = value.x
		$Camera2D.limit_bottom = value.y

var health := max_health:
	set(value):
		var old_health := health
		health = clampi(value, 0, max_health)
		if old_health > 0 and health == 0:
			died.emit()

var max_health: int:
	get:
		return (health_time
				* ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))

var position_public_visibility := true:
	set(value):
		position_public_visibility = value
		if multiplayer.is_server() and value:
			sync_position_reliable.rpc(_serialize_position(position))

var _is_ready := false


func _ready():
	$Camera2D.enabled = peer_id == multiplayer.get_unique_id()
	_is_ready = true


func sync_move_and_slide() -> bool:
	var result := move_and_slide()
	if not multiplayer.is_server():
		return result

	if position_public_visibility:
		sync_position.rpc(_serialize_position(position))

	elif peer_id != 1:
		sync_position.rpc_id(controller.peer_id, _serialize_position(position))

	return result


@rpc("unreliable_ordered")
func sync_position(serialized_position: int) -> void:
	position = _unserialize_position(serialized_position)


@rpc("reliable")
func sync_position_reliable(serialized_position: int) -> void:
	position = _unserialize_position(serialized_position)


func take_damage(source: DamageSource) -> void:
	$StateMachine.handle_damage(source)


func _serialize_position(unserialized_position: Vector2) -> int:
	var serialized_position := 0
	serialized_position |= roundi(unserialized_position.x * AXIS_MULTIPLIER)
	serialized_position |= roundi(unserialized_position.y * AXIS_MULTIPLIER) << AXIS_BITS
	return serialized_position


func _unserialize_position(serialized_position: int) -> Vector2:
	return Vector2(
			float(serialized_position & AXIS_MASK) / AXIS_MULTIPLIER,
			float((serialized_position & (AXIS_MASK << AXIS_BITS)) >> AXIS_BITS) / AXIS_MULTIPLIER
	)
