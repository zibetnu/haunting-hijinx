class_name Item
extends Area2D


func _acquirer_allowed(_acquirer: Variant) -> bool:
	return false


func _on_acquired(_acquirer: Variant) -> void:
	pass


func _on_entered(acquirer: Variant) -> void:
	if not _acquirer_allowed(acquirer):
		return

	if not multiplayer.is_server():
		return

	_on_acquired(acquirer)
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	_on_entered(area)


func _on_body_entered(body: Node2D) -> void:
	_on_entered(body)
