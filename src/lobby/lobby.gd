extends Control

const CLOSE_CONNECTION_ACTION = &"ui_cancel"
const MIN_PARTICIPANTS = 1
const PLAYER_TYPE_METHOD = &"set_player_type"
const PLAYER_TYPE_SIGNAL = &"player_type_changed"
const TOGGLE_BUTTON_PATH = ^"%ParticipationToggle"

@export var level: PackedScene
@export var player_card: PackedScene

@onready var cards: VBoxContainer = %Cards
@onready var host_menu: GridContainer = %HostMenu
@onready var leave: Button = %Leave
@onready var start_button: Button = %StartButton


func _ready() -> void:
	host_menu.visible = multiplayer.is_server()

	# Only the server needs to spawn the players.
	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	PeerData.peer_participation_changed.connect(_on_peer_participation_changed)
	for peer_id: int in PeerData.participants + PeerData.spectators:
		add_card(peer_id)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(CLOSE_CONNECTION_ACTION):
		leave.pressed.emit()  # Act as though leave button was pressed.


func add_card(id: int) -> void:
	var card: PlayerCard = player_card.instantiate()
	card.name += str(id)
	card.input_authority = id
	card.player_name_changed.connect(
			func(value: String) -> void: PeerData.set_peer_name(id, value)
	)
	if card.has_signal(PLAYER_TYPE_SIGNAL):
		card.connect(
				PLAYER_TYPE_SIGNAL,
				func(value: int)-> void: PeerData.set_peer_type(id, value)
		)
	cards.add_child(card, true)
	if card.has_method(PLAYER_TYPE_METHOD):
		card.call(PLAYER_TYPE_METHOD, PeerData.get_peer_type(id))

	_on_peer_participation_changed(id)


func _on_connection_closed() -> void:
	# https://github.com/godotengine/godot/issues/77643
	@warning_ignore("unsafe_method_access")
	SceneChanger.change_to_lobby_browser()


func _on_peer_connected(id: int) -> void:
	add_card(id)


func _on_peer_disconnected(id: int) -> void:
	for card: PlayerCard in cards.get_children():
		if card.input_authority == id:
			card.queue_free()


func _on_peer_participation_changed(_id: int) -> void:
	if not multiplayer.is_server():
		return

	start_button.disabled = PeerData.participants.size() < MIN_PARTICIPANTS


func _on_start_button_pressed() -> void:
	# https://github.com/godotengine/godot/issues/77643
	@warning_ignore("unsafe_method_access")
	SceneChanger.change_scene_to_packed(level)
