class_name Aura
extends Area2D

@export var intensity := 1


func _on_entered(node: Node) -> void:
	if node.has_method("add_aura"):
		node.add_aura(self)


func _on_exited(node: Node) -> void:
	if node.has_method("remove_aura"):
		node.remove_aura(self)


func _on_area_entered(area: Area2D) -> void:
	_on_entered(area)


func _on_area_exited(area: Area2D) -> void:
	_on_exited(area)


func _on_body_entered(body: Node2D) -> void:
	_on_entered(body)


func _on_body_exited(body: Node2D) -> void:
	_on_exited(body)
