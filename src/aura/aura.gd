extends Area2D


@export var intensity := 1
@export var outline_visible := false:
	set(value):
		outline_visible = value
		queue_redraw()


func _draw() -> void:
	var radius = $CollisionShape2D.shape.get("radius")
	draw_arc(position, radius if radius != null else 10, 0, 2 * PI, 32, Color8(255, 255, 255, 63))


func hide_outline() -> void:
	outline_visible = false


func show_outline() -> void:
	outline_visible = true


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
