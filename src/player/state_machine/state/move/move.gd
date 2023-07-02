extends State


@export var idle_state: State
@export var speed_multiplier := 1.0


func physics_update(_delta: float) -> void:
	if player.controller.move_vector == Vector2.ZERO:
		if multiplayer.is_server():
			state_machine.transition_to.rpc(idle_state.name)

	player.velocity = player.controller.move_vector * player.move_speed * speed_multiplier
	player.sync_move_and_slide()
