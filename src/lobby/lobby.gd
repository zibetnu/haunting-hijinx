extends Control


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
		ConnectionManager.close_connection()
		SceneChanger.change_scene_to_packed(SceneChanger.main_menu)


func add_participant(id: int) -> void:
	var card := _instantiate_card(id)
	%ActiveCards.add_child(card, true)
	%GhostSelector.add_item(PeerData.peer_names[card.peer_id], card.peer_id)


func add_spectator(id: int) -> void:
	var card := _instantiate_card(id)
	%SpectateCards.add_child(card, true)
	%GhostSelector.add_item(PeerData.peer_names[card.peer_id], card.peer_id)
	%GhostSelector.set_item_disabled(%GhostSelector.get_item_index(id), true)


func _instantiate_card(id: int) -> Node:
	var card = player_card.instantiate()
	card.name += str(id)
	card.peer_id = id
	return card


func _on_ghost_peer_changed(id: int) -> void:
	%GhostSelector.select(%GhostSelector.get_item_index(id))


func _on_peer_connected(id: int) -> void:
	if id in PeerData.participants:
		add_participant(id)

	elif id in PeerData.spectators:
		add_spectator(id)


func _on_peer_disconnected(id: int) -> void:
	for card in %ActiveCards.get_children() + %SpectateCards.get_children():
		if card.peer_id == id:
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

	%StartButton.disabled = PeerData.participants.size() < PeerData.MIN_PARTICIPANTS
	for card in %ActiveCards.get_children() + %SpectateCards.get_children():
		if card.peer_id != id:
			continue

		if id in PeerData.participants:
			card.reparent(%ActiveCards)
			card.ready.emit()  # Fix for MultiplayerSpawner error.

		elif id in PeerData.spectators:
			card.reparent(%SpectateCards)
			card.ready.emit()  # Fix for MultiplayerSpawner error.


func _on_start_button_pressed() -> void:
		PeerData.ghost_peer = %GhostSelector.get_selected_id()
		SceneChanger.change_scene_to_packed(level)
