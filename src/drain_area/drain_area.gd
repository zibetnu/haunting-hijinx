extends Area2D


@export var damage_source: DamageSource

var _affected := []


func _on_area_entered(area: Area2D) -> void:
	if not area in _affected:
		_affected.append(area)


func _on_area_exited(area: Area2D) -> void:
	_affected.erase(area)


func _on_body_entered(body: Node2D) -> void:
	if not body in _affected:
		_affected.append(body)


func _on_body_exited(body: Node2D) -> void:
	_affected.erase(body)


func _on_timer_timeout() -> void:
	for node in _affected:
		if node.has_method("take_damage"):
			node.take_damage(damage_source)

	if not multiplayer.is_server():
		return

	queue_free()
