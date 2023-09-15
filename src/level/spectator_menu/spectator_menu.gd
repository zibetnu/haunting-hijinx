extends Control


var spectating_index := 0:
	set(value):
		if value >= PeerData.participants.size():
			spectating_index = 0

		elif value < 0:
			spectating_index = PeerData.participants.size() - 1

		else:
			spectating_index = value

		_set_active_camera()


func _ready() -> void:
	_set_active_camera()
	%RightButton.grab_focus()


func _on_left_button_pressed() -> void:
	spectating_index -= 1


func _on_right_button_pressed() -> void:
	spectating_index += 1


func _set_active_camera() -> void:
	for player in get_tree().get_nodes_in_group("players"):
		player.get_node("Camera2D").enabled = player.peer_id == PeerData.participants[spectating_index]

	%SpectatingLabel.text = PeerData.peer_names.get(PeerData.participants[spectating_index], "username")
