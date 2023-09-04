extends Ability


@export var intensity := 1
@export var radius := 32:
	set(value):
		radius = value
		%CollisionShape2D.shape.radius = value


func _ready() -> void:
	visible = player.peer_id == multiplayer.get_unique_id()


func _draw() -> void:
	draw_arc(position, radius, 0, 2 * PI, 32, Color8(255, 255, 255, 63))


func _on_entered(node: Node) -> void:
	if not multiplayer.is_server():
		return

	if not node.owner:
		return

	if not node.owner.has_method("add_aura"):
		return

	node.owner.add_aura(self)


func _on_exited(node: Node) -> void:
	if not multiplayer.is_server():
		return

	if not node.owner:
		return

	if not node.owner.has_method("remove_aura"):
		return

	node.owner.remove_aura(self)


func _on_area_2d_area_entered(area: Area2D) -> void:
	_on_entered(area)


func _on_area_2d_area_exited(area: Area2D) -> void:
	_on_exited(area)


func _on_area_2d_body_entered(body: Node2D) -> void:
	_on_entered(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	_on_exited(body)


func _on_player_state_machine_transitioned(state_name: String) -> void:
	$Area2D.monitoring = state_name in _state_names
