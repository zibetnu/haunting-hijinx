extends Control


@export var aura_sense: AuraSense:
	set(value):
		_disconnect_signal()
		aura_sense = value
		_connect_signal()


func _ready() -> void:
	_connect_signal()


func _connect_signal() -> void:
	if aura_sense:
		aura_sense.sensed_intensity_changed.connect(_on_sensed_intensity_changed)


func _disconnect_signal() -> void:
	if aura_sense:
		aura_sense.sensed_intensity_changed.disconnect(_on_sensed_intensity_changed)


func _on_sensed_intensity_changed(intensity: int) -> void:
	var valid_player := (
			aura_sense.player.peer_id == multiplayer.get_unique_id()
			or PeerData.ghost_peer == multiplayer.get_unique_id()
	)
	visible = valid_player and intensity > 0
	if intensity <= 0:
		$AnimationPlayer.play("RESET")

	elif intensity == 1:
		$AnimationPlayer.play("alert_low")

	elif aura_sense.sensed_intensity > 1:
		$AnimationPlayer.play("alert_high")
