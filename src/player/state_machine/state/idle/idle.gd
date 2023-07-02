extends State


@export var move_state: State


func physics_update(_delta: float) -> void:
	if not multiplayer.is_server():
		return

	if player.controller.move_vector == Vector2.ZERO:
		return

	state_machine.transition_to.rpc(move_state.name)
