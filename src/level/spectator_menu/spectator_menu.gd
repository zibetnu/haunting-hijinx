extends Control


const _CAMERA_PATH = ^"%Camera2D"
const _NAME_LABEL_PATH = ^"%NameLabel"
const _PLAYER_GROUP = &"players"
const _UNKNOWN_NAME = "name unknown"

var spectate_index := 0:
	set(value):
		if value >= _players.size():
			spectate_index = 0

		elif value < 0:
			spectate_index = _players.size() - 1

		else:
			spectate_index = value

		_spectate_player_at_index()

var _players: Array[Node]:
	get:
		return get_tree().get_nodes_in_group(_PLAYER_GROUP)

@onready var _left_button := %LeftButton
@onready var _right_button := %RightButton
@onready var _spectating_label := %SpectatingLabel


func _ready() -> void:
	await get_tree().process_frame  # Wait until players are set up.
	_right_button.grab_focus()
	_spectate_player_at_index()


func _on_left_button_pressed() -> void:
	spectate_index -= 1


func _on_right_button_pressed() -> void:
	spectate_index += 1


func _on_cutscene_ended(_cutscene_name: String) -> void:
	_left_button.disabled = false
	_right_button.disabled = false
	_spectate_player_at_index()


func _on_cutscene_started(_cutscene_name: String) -> void:
	_left_button.disabled = true
	_right_button.disabled = true


func _spectate_player_at_index() -> void:
	if _players.is_empty():
		return

	for player in _players:
		var camera: Camera2D = player.get_node_or_null(_CAMERA_PATH)
		if camera:
			camera.enabled = player == _players[spectate_index]

	var label: Label = _players[spectate_index].get_node_or_null(_NAME_LABEL_PATH)
	_spectating_label.text = label.text if label else _UNKNOWN_NAME
