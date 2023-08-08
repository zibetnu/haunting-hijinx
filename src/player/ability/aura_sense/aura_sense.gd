extends Ability


@export var dead_exit_trigger: ExitTrigger

var active := false:
	set(value):
		active = value
		$Label.visible = active and player.peer_id == multiplayer.get_unique_id()

var _sensed_auras: Array[Node] = []


func _ready() -> void:
	super()
	dead_exit_trigger.triggered.connect(_on_dead_exit_trigger_triggered)


func remove_aura(source: Node) -> void:
	if not source in _sensed_auras:
		return

	_sensed_auras.erase(source)
	_update_label_text()


func add_aura(source: Node) -> void:
	if not "intensity" in source:
		return

	if source in _sensed_auras:
		return

	_sensed_auras.append(source)
	_update_label_text()


@rpc("unreliable_ordered")
func _sync_label_text(value: String) -> void:
	$Label.text = value


func _update_label_text() -> void:
	if not multiplayer.is_server():
		return

	if not active:
		return

	$Label.text = ""
	if _sensed_auras.size() > 0:
		_sensed_auras.sort_custom(func(a, b): return a.intensity > b.intensity)
		for _i in range(_sensed_auras[0].intensity):
			$Label.text += "!"

	if not player.peer_id in multiplayer.get_peers():
		return

	_sync_label_text.rpc_id(player.peer_id, $Label.text)


func _on_dead_exit_trigger_triggered() -> void:
	active = player.state_machine.state.name in _state_names
	_update_label_text()


func _on_player_state_machine_transitioned(state_name: String) -> void:
	active = state_name in _state_names
