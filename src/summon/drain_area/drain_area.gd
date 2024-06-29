extends Area2D


signal activated

const IDLE_PARAMETERS = {
	"amplitude": 1,
	"frequency": -4,
	"ripple_rate": 6,
}
const ACTIVE_PARAMETERS = {
	"amplitude": 2,
	"frequency": 4,
	"ripple_rate": 12,
}
const DAMAGE_METHOD = &"take_damage"

@export var damage_source: DamageSource

var _active := false
var _affected_collision_objects: Array[CollisionObject2D] = []

@onready var _active_timer: Timer = $ActiveTimer
@onready var _waves_material: ShaderMaterial = ($Waves as ColorRect).material


func _ready() -> void:
	_set_parameters_from_dictionary(IDLE_PARAMETERS)


func activate() -> void:
	if not multiplayer.is_server():
		return

	_active = true
	activated.emit()
	_damage_affected_collision_objects()
	_set_parameters_from_dictionary(ACTIVE_PARAMETERS)
	_active_timer.start()


func _damage_affected_collision_objects() -> void:
	if not _active:
		return

	for collision_object in _affected_collision_objects:
		if not collision_object.has_method(DAMAGE_METHOD):
			continue

		collision_object.call(DAMAGE_METHOD, damage_source)

		if multiplayer.is_server():
			queue_free()


func _on_entered(collision_object: CollisionObject2D) -> void:
	if collision_object in _affected_collision_objects:
		return

	_affected_collision_objects.append(collision_object)
	_damage_affected_collision_objects()


func _on_exited(collision_object: CollisionObject2D) -> void:
	_affected_collision_objects.erase(collision_object)


func _set_parameters_from_dictionary(parameters: Dictionary) -> void:
	for key: String in parameters:
		_waves_material.set_shader_parameter(key, parameters[key])
