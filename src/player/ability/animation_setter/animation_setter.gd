extends Ability


@export var animation_name: String


func _on_player_state_machine_transitioned(state_name: String) -> void:
	if not state_name in _state_names:
		return

	player.costume.animation_name = animation_name
