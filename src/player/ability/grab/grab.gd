extends Ability


@export var grab_state: State
@export var raycast_parent: Node
@export var damage_source : DamageSource


func _on_player_state_machine_transitioned(state_name: String) -> void:
	set_physics_process(state_name in _state_names)


func _physics_process(_delta: float) -> void:
	for child in raycast_parent.get_children():
		if not child is RayCast2D:
			continue

		if not child.is_colliding():
			continue

		var collider = child.get_collider()
		if not collider.has_method("take_damage"):
			continue

		if multiplayer.is_server():
			player.state_machine.transition_to.rpc(grab_state.name)

		collider.take_damage(damage_source)
		return
