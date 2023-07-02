extends Ability


var active := false

var _sensed_auras: Array[Node] = []


func remove_aura(source: Node) -> void:
	if not multiplayer.is_server():
		return

	if not source in _sensed_auras:
		return

	_sensed_auras.erase(source)
	_update_label_text()


func add_aura(source: Node) -> void:
	if not multiplayer.is_server():
		return

	if not "intensity" in source:
		return

	if source in _sensed_auras:
		return

	_sensed_auras.append(source)
	_update_label_text()


@rpc("call_local")
func _sync_label_text(value: String) -> void:
	$Label.text = value


func _update_label_text() -> void:
	if not multiplayer.is_server():
		return

	$Label.text = ""
	if _sensed_auras.size() > 0:
		_sensed_auras.sort_custom(func(a, b): return a.intensity > b.intensity)
		for _i in range(_sensed_auras[0].intensity):
			$Label.text += "! "

	if not active:
		return

	if player.peer_id == multiplayer.get_unique_id():
		return

	_sync_label_text.rpc_id(player.peer_id, $Label.text)


func _on_player_state_machine_transitioned(state_name: String) -> void:
	active = state_name in _state_names
	$Area2D.monitoring = active
	$Area2D.monitorable = active
	$Label.visible = active and player.peer_id == multiplayer.get_unique_id()
	if not active:
		$Label.text = ""
