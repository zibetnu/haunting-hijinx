extends State


var _previous_collision_layer: int


func enter(_message := {}) -> void:
	# Prevent player positions from occasionally desyncing on death.
	player.sync_position_reliable(player.serialize_position(player.position))
	_previous_collision_layer = player.collision_layer
	player.collision_layer = 8  # Put player on spectral layer only.


func exit() -> void:
	player.collision_layer = _previous_collision_layer
