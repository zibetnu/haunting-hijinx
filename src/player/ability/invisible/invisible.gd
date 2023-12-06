extends Ability


var active := false:
	set(value):
		if active == value:
			return

		active = value
		var make_visible := false
		if active:
			player.position_public_visibility = false
			player.modulate.a = 0.5
			make_visible = player.peer_id == multiplayer.get_unique_id()

		else:
			player.position_public_visibility = true
			player.modulate.a = 1
			make_visible = true

		player.visible = make_visible
		player.get_node("IgnoreCanvasModulate").visible = make_visible


func _on_player_state_machine_transitioned(state_name: String) -> void:
	active = state_name in _state_names
