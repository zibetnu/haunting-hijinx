extends Area2D


@export var damage_source: DamageSource

var _active := false
var _affected_collision_objects: Array[CollisionObject2D] = []


func _damage_affected_collision_objects() -> void:
	if not _active:
		return

	for collision_object in _affected_collision_objects:
		if not collision_object.has_method("take_damage"):
			continue

		collision_object.take_damage(damage_source)
		if multiplayer.is_server():
			queue_free()


func _on_area_entered(area: Area2D) -> void:
	_on_entered(area)


func _on_area_exited(area: Area2D) -> void:
	_on_exited(area)


func _on_body_entered(body: PhysicsBody2D) -> void:
	_on_entered(body)


func _on_body_exited(body: PhysicsBody2D) -> void:
	_on_exited(body)


func _on_entered(collision_object: CollisionObject2D) -> void:
	if collision_object in _affected_collision_objects:
		return

	_affected_collision_objects.append(collision_object)
	_damage_affected_collision_objects()


func _on_exited(collision_object: CollisionObject2D) -> void:
	_affected_collision_objects.erase(collision_object)


func _on_idle_timer_timeout() -> void:
	_active = true
	_damage_affected_collision_objects()
	$Foreground.material.set_shader_parameter("amplitude", 2)
	$Foreground.material.set_shader_parameter("frequency", 4)
	$Foreground.material.set_shader_parameter("ripple_rate", 12)
	$ActiveTimer.start()


func _on_active_timer_timeout() -> void:
	if multiplayer.is_server():
		queue_free()
