extends PanelContainer


signal player_name_changed(value: String)

@export var input_authority := 1:
	set(value):
		input_authority = value
		%InputSynchronizer.set_multiplayer_authority(value)
		%IDLabel.text = str(value)

var player_name: String:
	set(value):
		player_name = value
		player_name_changed.emit(player_name)
		%NameLabel.text = value


func _ready() -> void:
	PeerData.peer_participation_changed.connect(_on_peer_participation_changed)
	player_name = "Player %s" % str(multiplayer.get_unique_id())
	%NameLineEdit.text = player_name
	%NameLineEdit.visible = multiplayer.get_unique_id() == input_authority
	%NameLabel.visible = not %NameLineEdit.visible
	%ParticipationToggle.visible = multiplayer.is_server()
	_on_peer_participation_changed(input_authority)


func set_player_name(value: String) -> void:
	player_name = value


func _on_participation_toggle_pressed() -> void:
	PeerData.toggle_participation(input_authority)


func _on_peer_participation_changed(_id: int) -> void:
	if input_authority in PeerData.participants:
		%ParticipationToggle.disabled = false
		%ParticipationToggle.text = ">>"

	else:
		%ParticipationToggle.disabled = PeerData.participants.size() >= PeerData.MAX_PARTICIPANTS
		%ParticipationToggle.text = "<<"
