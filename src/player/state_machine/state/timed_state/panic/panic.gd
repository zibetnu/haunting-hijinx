class_name Panic
extends TimedState


@export var speed_multiplier := 2


func physics_update(_delta: float) -> void:
	player.velocity = player.controller.move_vector * player.move_speed * speed_multiplier
	player.sync_move_and_slide()
