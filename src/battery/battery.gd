extends Area2D


const ACQUIRER_PROPERTY = &"battery_percentage"
const ACQUIRER_VALUE = 1.0
const BOB_NAME = &"bob"
const DESTROY_NAME = &"destroy"
const SPAWN_NAME = &"spawn"

@export var weak_to: DamageSource.Type

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	_animation_player.play(SPAWN_NAME)
	await _animation_player.animation_finished
	_animation_player.play(BOB_NAME)


@rpc("call_local")
func destoy() -> void:
	_animation_player.play(DESTROY_NAME)
	_collision_shape_2d.disabled = true
	await _animation_player.animation_finished
	if multiplayer.is_server():
		queue_free()


func take_damage(source: DamageSource) -> void:
	if source.damage_type != weak_to:
		return

	if multiplayer.is_server():
		destoy.rpc()


func _on_entered(acquirer: Object) -> void:
	if not ACQUIRER_PROPERTY in acquirer:
		return

	if not multiplayer.is_server():
		return

	acquirer.set(ACQUIRER_PROPERTY, ACQUIRER_VALUE)
	queue_free()
