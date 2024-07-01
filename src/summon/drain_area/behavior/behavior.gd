extends Area2D


signal active_ended
signal active_started

const DAMAGE_METHOD = &"take_damage"
const DESTROY_GROUP = &"batteries"
const DESTROY_METHOD = &"destroy"

@export var damage_source: DamageSource

var _active := false
var _affected_collision_objects: Array[CollisionObject2D] = []

@onready var _active_timer: Timer = $ActiveTimer


func end_active() -> void:
	_active = false
	active_ended.emit()
	_active_timer.stop()


func start_active() -> void:
	_active = true
	active_started.emit()
	get_tree().call_group(DESTROY_GROUP, DESTROY_METHOD)
	_damage_affected_collision_objects()
	_active_timer.start()


func _damage_affected_collision_objects() -> void:
	if not _active:
		return

	for collision_object in _affected_collision_objects:
		if not collision_object.has_method(DAMAGE_METHOD):
			continue

		collision_object.call(DAMAGE_METHOD, damage_source)
		end_active()


func _on_entered(collision_object: CollisionObject2D) -> void:
	if collision_object in _affected_collision_objects:
		return

	_affected_collision_objects.append(collision_object)
	_damage_affected_collision_objects()


func _on_exited(collision_object: CollisionObject2D) -> void:
	_affected_collision_objects.erase(collision_object)
