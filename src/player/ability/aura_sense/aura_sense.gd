class_name AuraSense
extends Ability


signal sensed_intensity_changed(intensity: int)

@export var dead_exit_trigger: ExitTrigger

var active := false:
	set(value):
		active = value
		if not active:
			sensed_intensity = 0

var sensed_intensity: int:
	set(value):
		sensed_intensity = value
		sensed_intensity_changed.emit(value)

var _sensed_auras: Array[Node] = []


func _ready() -> void:
	super()
	dead_exit_trigger.triggered.connect(_on_dead_exit_trigger_triggered)


func remove_aura(source: Node) -> void:
	if not source in _sensed_auras:
		return

	_sensed_auras.erase(source)
	_update_sensed_intensity()


func add_aura(source: Node) -> void:
	if not "intensity" in source:
		return

	if source in _sensed_auras:
		return

	_sensed_auras.append(source)
	_update_sensed_intensity()


@rpc("reliable")
func _sync_sensed_intensity(value: int) -> void:
	sensed_intensity = value


func _update_sensed_intensity() -> void:
	if not multiplayer.is_server():
		return

	if not active:
		return

	if _sensed_auras.size() > 0:
		_sensed_auras.sort_custom(func(a, b): return a.intensity > b.intensity)
		sensed_intensity = _sensed_auras[0].intensity

	else:
		sensed_intensity = 0

	if not player.peer_id in multiplayer.get_peers():
		return

	_sync_sensed_intensity.rpc_id(player.peer_id, sensed_intensity)


func _on_dead_exit_trigger_triggered() -> void:
	active = player.state_machine.state.name in _state_names
	_update_sensed_intensity()


func _on_player_state_machine_transitioned(state_name: String) -> void:
	active = state_name in _state_names
