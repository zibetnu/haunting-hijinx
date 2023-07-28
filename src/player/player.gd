class_name Player
extends CharacterBody2D


signal died
signal peer_id_changed(id: int)
signal revived

@export var controller: Controller
@export var costume: Costume
@export var max_health := 100
@export var modifier_manager: ModifierManager
@export var move_speed := 40
@export var peer_id := 1:
	set(value):
		peer_id = value
		if "peer_id" in controller:
			controller.peer_id = value

		peer_id_changed.emit(value)

@export var state_machine: StateMachine

var position_public_visibility := true:
	set(value):
		position_public_visibility = value
		if multiplayer.is_server() and value:
			sync_position.rpc(position)

@onready var health := max_health:
	set(value):
		var old_health := health
		health = clampi(value, 0, max_health)
		if old_health > 0 and health == 0:
			died.emit()


func sync_move_and_slide() -> bool:
	var result := move_and_slide()
	if not multiplayer.is_server():
		return result

	if position_public_visibility:
		sync_position.rpc(position)

	elif peer_id != 1:
		sync_position.rpc_id(controller.peer_id, position)

	return result


@rpc("unreliable_ordered")
func sync_position(value: Vector2) -> void:
	position = value


func take_damage(source: DamageSource) -> void:
	$StateMachine.handle_damage(source)
