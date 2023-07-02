class_name StandardDamageHandler
extends DamageHandler


@export var dead_state: State
@export var weak_to: DamageSource.Type


func handle_damage(source: DamageSource, affected_player: Player) -> void:
	if source.damage_type != weak_to:
		return

	affected_player.health -= source.damage_amount
	if affected_player.health != 0:
		return

	if multiplayer.is_server():
		affected_player.state_machine.transition_to.rpc(dead_state.name)
