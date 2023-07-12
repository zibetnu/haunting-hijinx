extends ExitTrigger


@export var duration := 5.0
@export var player_alpha := 1.0:
	get:
		return player.modulate.a

	set(value):
		player.modulate.a = value

var _previous_collision_layer: int


func _trigger() -> void:
	_previous_collision_layer = player.collision_layer
	player.collision_layer = 16  # Put player on invulnerable layer.
	$AnimationPlayer.play("flash")

	await get_tree().create_timer(duration).timeout

	player.collision_layer = _previous_collision_layer
	$AnimationPlayer.play("RESET")
