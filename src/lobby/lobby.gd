extends Control


signal close_connection_requested

const AUTOLOAD_LOBBY_PROPERTY := &"lobby_id"
const AUTOLOAD_PATH := ^"/root/PeerData"
const MIN_PARTICIPANTS = 1
const TOGGLE_BUTTON_PATH = ^"%ParticipationToggle"

@export var level: PackedScene
@export var player_card: PackedScene


func _ready():
	%HostMenu.visible = multiplayer.is_server()

	# Only the server needs to spawn the players.
	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	PeerData.ghost_peer_changed.connect(_on_ghost_peer_changed)
	PeerData.peer_name_changed.connect(_on_peer_name_changed)
	PeerData.peer_participation_changed.connect(_on_peer_participation_changed)

	for peer_id in PeerData.participants:
		add_participant(peer_id)

	for peer_id in PeerData.spectators:
		add_spectator(peer_id)

	_on_ghost_peer_changed(PeerData.ghost_peer)
	%GhostSelector.grab_focus()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_connection_requested.emit()


func add_participant(id: int) -> void:
	var card := _instantiate_card(id)
	%ActiveCards.add_child(card, true)
	%GhostSelector.add_item(PeerData.peer_names[card.input_authority], card.input_authority)


func add_spectator(id: int) -> void:
	var card := _instantiate_card(id)
	%SpectateCards.add_child(card, true)
	%GhostSelector.add_item(PeerData.peer_names[card.input_authority], card.input_authority)
	%GhostSelector.set_item_disabled(%GhostSelector.get_item_index(id), true)


func _get_autoload_lobby_id() -> Variant:
	var autoload := get_node_or_null(AUTOLOAD_PATH)
	if autoload:
		return autoload.get(AUTOLOAD_LOBBY_PROPERTY)

	return null


func _instantiate_card(id: int) -> Node:
	var card = player_card.instantiate()
	card.name += str(id)
	card.input_authority = id
	card.player_name_changed.connect(func(value): PeerData.set_peer_name(id, value))
	return card


func _on_connection_closed() -> void:
	SceneChanger.change_to_lobby_browser()


func _on_ghost_peer_changed(id: int) -> void:
	%GhostSelector.select(%GhostSelector.get_item_index(id))


func _on_peer_connected(id: int) -> void:
	if id in PeerData.participants:
		add_participant(id)

	elif id in PeerData.spectators:
		add_spectator(id)


func _on_peer_disconnected(id: int) -> void:
	for card in %ActiveCards.get_children() + %SpectateCards.get_children():
		if card.input_authority == id:
			card.queue_free()

	if %GhostSelector.get_item_index(id) != -1:
		%GhostSelector.remove_item(%GhostSelector.get_item_index(id))
		%GhostSelector.select(%GhostSelector.get_selectable_item())


func _on_peer_name_changed(id: int) -> void:
	var index: int = %GhostSelector.get_item_index(id)
	if index == -1:
		return

	%GhostSelector.set_item_text(index, PeerData.peer_names[id])


func _on_peer_participation_changed(id: int) -> void:
	var disabled := not (id in PeerData.participants)
	%GhostSelector.set_item_disabled(%GhostSelector.get_item_index(id), disabled)

	# In cases where the selected id may be disabled or
	# no id is selected, select the first available id.
	if disabled or %GhostSelector.get_selected_id() == -1:
		%GhostSelector.select(%GhostSelector.get_selectable_item())

	%StartButton.disabled = PeerData.participants.size() < MIN_PARTICIPANTS
	for card in %ActiveCards.get_children() + %SpectateCards.get_children():
		if card.input_authority != id:
			continue

		var player_name: String = card.player_name
		var input_authority: int = card.input_authority
		card.queue_free()
		var new_card = _instantiate_card(input_authority)
		new_card.player_name = player_name

		if id in PeerData.participants:
			%ActiveCards.add_child(new_card, true)

		elif id in PeerData.spectators:
			%SpectateCards.add_child(new_card, true)

		# Grab focus again after it was lost by freeing the prior card.
		var toggle_button := new_card.get_node_or_null(TOGGLE_BUTTON_PATH) as Button
		if toggle_button != null:
			toggle_button.grab_focus.call_deferred()


func _on_start_button_pressed() -> void:
	PeerData.ghost_peer = %GhostSelector.get_selected_id()
	SceneChanger.change_scene_to_packed(level)
