extends PanelContainer


signal player_name_changed(value: String)
signal player_type_changed(value: PlayerType)

const AUTOLOAD_NAMES_PROPERTY := &"peer_names"
const AUTOLOAD_PATH := ^"/root/PeerData"
const CARD_GROUP = &"player_cards"
const GROUP_METHOD = &"auto_set_player_type"
const MAX_GHOSTS = 1
const MAX_HUNTERS = 4

enum PlayerType {
	HUNTER = 0,
	GHOST = 1,
	SPECTATOR = 2,
}

@export var input_authority := 1:
	set(value):
		input_authority = value
		%InputSynchronizer.set_multiplayer_authority(value)

@export var player_type: PlayerType:
	set = set_player_type

var player_name: String:
	set = set_player_name

@onready var cycle_type: Button = %CycleType
@onready var name_line_edit: LineEdit = %NameLineEdit


func _ready() -> void:
	cycle_type.disabled = not multiplayer.is_server()
	var is_input_authority := multiplayer.get_unique_id() == input_authority
	name_line_edit.editable = is_input_authority
	if is_input_authority:
		name_line_edit.grab_focus()

	set_player_name(str(_get_autoload_peer_name(input_authority)))


func auto_set_player_type(caller: Node) -> void:
	if caller == self:
		return

	if player_type == PlayerType.SPECTATOR:
		return

	var cards: Array[Node] = get_tree().get_nodes_in_group(CARD_GROUP)
	var player_types: Array[PlayerType] = []
	player_types.assign(
		cards.map(func(card: Node) -> PlayerType: return card.get("player_type"))
	)

	var ghost_count: int = player_types.count(PlayerType.GHOST)
	var hunter_count: int = player_types.count(PlayerType.HUNTER)
	var new_player_type: PlayerType = player_type
	match player_type:
		PlayerType.HUNTER:
			var too_many_hunters: bool = hunter_count > MAX_HUNTERS
			if not too_many_hunters:
				return

			var ghosts_full: bool = ghost_count >= MAX_GHOSTS
			if not ghosts_full:
				new_player_type = PlayerType.GHOST

			else:
				new_player_type = PlayerType.SPECTATOR

		PlayerType.GHOST:
			var too_many_ghosts: bool = ghost_count > MAX_GHOSTS
			if not too_many_ghosts:
				return

			var hunters_full: bool = hunter_count >= MAX_HUNTERS
			if not hunters_full:
				new_player_type = PlayerType.HUNTER

			else:
				new_player_type = PlayerType.SPECTATOR

	set_player_type(new_player_type)


func cycle_player_type() -> void:
	set_player_type((player_type + 1) % PlayerType.size())


func set_player_name(value: String) -> void:
	player_name = value
	player_name_changed.emit(player_name)
	_set_text_keep_caret_column.call_deferred(player_name)


func set_player_type(value: PlayerType) -> void:
	player_type = value
	player_type_changed.emit(player_type)
	_call_card_group_sequentially()


func _call_card_group_sequentially() -> void:
	for card: Node in get_tree().get_nodes_in_group(CARD_GROUP):
		card.call(GROUP_METHOD, self)


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


func _set_text_keep_caret_column(text: String) -> void:
	var caret_column: int = name_line_edit.caret_column
	name_line_edit.text = text
	name_line_edit.caret_column = caret_column
