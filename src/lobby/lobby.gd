extends Control

const PLAYER_CARD_SCENE = preload("uid://bapt74v2o7kig")

@onready var cards: VBoxContainer = %Cards
@onready var leave: Button = %Leave
@onready var host_menu: GridContainer = %HostMenu
@onready var level_select: OptionButton = %LevelSelect
@onready var start_button: Button = %StartButton


func _ready() -> void:
	if not multiplayer.is_server():
		host_menu.queue_free()
		return

	for level in PeerData.levels:
		level_select.add_item(level.resource_name)

	level_select.select(PeerData.levels_selected_index)
	PeerData.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	PeerData.peer_participation_changed.connect(_on_peer_participation_changed)
	for peer_id: int in PeerData.participants + PeerData.spectators:
		add_card(peer_id)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		leave.pressed.emit()


func add_card(id: int) -> void:
	var card: PlayerCard = PLAYER_CARD_SCENE.instantiate()
	card.name += str(id)
	card.input_authority = id
	card.player_name_changed.connect(
			func(value: String) -> void: PeerData.set_peer_name(id, value)
	)
	card.player_type_changed.connect(
			func(value: int)-> void: PeerData.set_peer_type(id, value)
	)
	cards.add_child(card, true)
	card.set_player_type(PeerData.get_peer_type(id) as PlayerCard.PlayerType)
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

	if get_viewport().gui_get_focus_owner().owner.is_queued_for_deletion():
		leave.grab_focus()


func _on_peer_participation_changed(_id: int) -> void:
	if not multiplayer.is_server():
		return

	start_button.disabled = PeerData.participants.size() < 1


func _on_level_select_item_selected(index: int) -> void:
	PeerData.levels_selected_index = index


func _on_start_button_pressed() -> void:
	PeerData.assign_hunter_palettes()
	# https://github.com/godotengine/godot/issues/77643
	@warning_ignore("unsafe_method_access")
	SceneChanger.change_to_level(PeerData.get_selected_level())
