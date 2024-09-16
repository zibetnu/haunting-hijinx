extends Control


signal close_connection_requested

const CLOSE_CONNECTION_ACTION = &"ui_cancel"
const MIN_PARTICIPANTS = 1
const TOGGLE_BUTTON_PATH = ^"%ParticipationToggle"

@export var level: PackedScene
@export var player_card: PackedScene

@onready var active_cards: VBoxContainer = %ActiveCards
@onready var ghost_selector: OptionButton = %GhostSelector
@onready var host_menu: GridContainer = %HostMenu
@onready var spectate_cards: VBoxContainer = %SpectateCards
@onready var start_button: Button = %StartButton


func _ready() -> void:
	host_menu.visible = multiplayer.is_server()

	# Only the server needs to spawn the players.
	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	PeerData.ghost_peer_changed.connect(_on_ghost_peer_changed)
	PeerData.peer_name_changed.connect(_on_peer_name_changed)
	PeerData.peer_participation_changed.connect(_on_peer_participation_changed)

	for peer_id: int in PeerData.participants:
		add_participant(peer_id)

	for peer_id: int in PeerData.spectators:
		add_spectator(peer_id)

	_on_ghost_peer_changed(PeerData.ghost_peer)
	ghost_selector.grab_focus()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(CLOSE_CONNECTION_ACTION):
		close_connection_requested.emit()


func add_participant(id: int) -> void:
	var card: Node = _instantiate_card(id)
	active_cards.add_child(card, true)
	ghost_selector.add_item(
			str(PeerData.peer_names[card.input_authority]),
			card.input_authority
	)
	_on_peer_participation_changed(id)


func add_spectator(id: int) -> void:
	var card: Node = _instantiate_card(id)
	spectate_cards.add_child(card, true)
	ghost_selector.add_item(
			str(PeerData.peer_names[card.input_authority]),
			card.input_authority
	)
	_on_peer_participation_changed(id)


func _instantiate_card(id: int) -> Node:
	var card: Node = player_card.instantiate()
	card.name += str(id)
	card.input_authority = id
	card.player_name_changed.connect(
			func(value: String) -> void: PeerData.set_peer_name(id, value)
	)
	return card


func _multiplayer_reparent(child: Node, new_parent: Node) -> void:
		child.get_parent().remove_child(child)
		child.request_ready()
		new_parent.add_child(child, true)


func _on_connection_closed() -> void:
	SceneChanger.change_to_lobby_browser()


func _on_ghost_peer_changed(id: int) -> void:
	ghost_selector.select(ghost_selector.get_item_index(id))


func _on_peer_connected(id: int) -> void:
	if id in PeerData.participants:
		add_participant(id)

	elif id in PeerData.spectators:
		add_spectator(id)


func _on_peer_disconnected(id: int) -> void:
	for card in active_cards.get_children() + spectate_cards.get_children():
		if card.input_authority == id:
			card.queue_free()

	if ghost_selector.get_item_index(id) != -1:
		ghost_selector.remove_item(ghost_selector.get_item_index(id))
		ghost_selector.select(ghost_selector.get_selectable_item())


func _on_peer_name_changed(id: int) -> void:
	var index: int = ghost_selector.get_item_index(id)
	if index == -1:
		return

	ghost_selector.set_item_text(index, str(PeerData.peer_names[id]))


func _on_peer_participation_changed(id: int) -> void:
	if not multiplayer.is_server():
		return

	var is_participant: bool = id in PeerData.participants
	var is_spectator: bool = id in PeerData.spectators
	ghost_selector.set_item_disabled(
			ghost_selector.get_item_index(id), is_spectator
	)

	# In cases where the selected id may be disabled or
	# no id is selected, select the first available id.
	if is_spectator or ghost_selector.get_selected_id() == -1:
		ghost_selector.select(ghost_selector.get_selectable_item())

	start_button.disabled = PeerData.participants.size() < MIN_PARTICIPANTS
	for card in active_cards.get_children() + spectate_cards.get_children():
		if card.input_authority != id:
			continue

		var parent: Node = card.get_parent()
		if is_participant and parent == active_cards:
			continue

		if is_spectator and parent == spectate_cards:
			continue

		if is_participant:
			_multiplayer_reparent(card, active_cards)

		if is_spectator:
			_multiplayer_reparent(card, spectate_cards)

		# Grab focus again after it was lost by reparenting the card.
		var toggle_button := card.get_node_or_null(TOGGLE_BUTTON_PATH) as Button
		if toggle_button != null:
			toggle_button.grab_focus.call_deferred()


func _on_start_button_pressed() -> void:
	PeerData.ghost_peer = ghost_selector.get_selected_id()
	SceneChanger.change_scene_to_packed(level)
