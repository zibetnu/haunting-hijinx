extends PanelContainer


signal player_name_changed(value: String)

const AUTOLOAD_NAMES_PROPERTY := &"peer_names"
const AUTOLOAD_PATH := ^"/root/PeerData"

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
	var participation_signal: Signal = PeerData.peer_participation_changed
	var participation_receiver: Callable = _on_peer_participation_changed
	if not participation_signal.is_connected(participation_receiver):
		participation_signal.connect(participation_receiver)

	set_player_name(str(_get_autoload_peer_name(input_authority)), true)
	%NameLineEdit.visible = multiplayer.get_unique_id() == input_authority
	%NameLabel.visible = not %NameLineEdit.visible
	%ParticipationToggle.visible = multiplayer.is_server()
	_on_peer_participation_changed(input_authority)


func set_player_name(value: String, update_line_edit := false) -> void:
	player_name = value
	if update_line_edit:
		%NameLineEdit.text = player_name


func _get_autoload_peer_name(id: int) -> Variant:
	var autoload := get_node_or_null(AUTOLOAD_PATH)
	if not autoload:
		return null

	var peer_names = autoload.get(AUTOLOAD_NAMES_PROPERTY)
	if not peer_names is Dictionary:
		return null

	return peer_names.get(id)


func _on_participation_toggle_pressed() -> void:
	PeerData.toggle_participation(input_authority)


func _on_peer_participation_changed(_id: int) -> void:
	if input_authority in PeerData.participants:
		%ParticipationToggle.disabled = false
		%ParticipationToggle.text = ">>"

	else:
		%ParticipationToggle.disabled = PeerData.participants.size() >= PeerData.MAX_PARTICIPANTS
		%ParticipationToggle.text = "<<"
