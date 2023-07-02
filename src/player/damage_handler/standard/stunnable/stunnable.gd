extends StandardDamageHandler


@export var stun_state: State


func handle_damage(source: DamageSource, affected_player: Player) -> void:
	super(source, affected_player)

	if source.damage_type != weak_to:
		return

	if affected_player.health == 0:
		return

	if multiplayer.is_server():
		affected_player.state_machine.transition_to.rpc(stun_state.name)
