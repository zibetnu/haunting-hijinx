extends Control


signal join_lobby_requested(lobby_id: int)

const REFRESH_TEXT = "Refresh"
const DISABLE_WHILE_NOT_REFRESHING = false

const REFRESHING_TEXT = "Refreshing..."
const DISABLE_WHILE_REFRESHING = true

const NAME_KEY = "name"

const LOCATION_KEY = "location"
const PARSED_SUCCESS_KEY = "success"
const PARSED_SUCCESS_DEFAULT = false
const PARSED_LOCATION_KEY = "ping_location"

const JOIN_TIMEOUT_SEC = 30.0
const JOIN_FAILED_MESSAGE = "Failed to join lobby. Try restarting the game."

const SCENE_CHANGER_PATH = ^"/root/SceneChanger"
const LOBBY_METHOD = &"change_to_lobby"
const MAIN_MENU_METHOD = &"change_to_main_menu"

@export var first_button: Button
@export var lobby_summary_scene: PackedScene

@onready var joining_window: Window = %JoiningWindow
@onready var summary_container: VBoxContainer = %LobbySummaries
@onready var notify_dialog: AcceptDialog = %NotifyDialog
@onready var refresh_button: Button = %Refresh


func _ready() -> void:
	# Free self and let server load lobby.
	multiplayer.connected_to_server.connect(queue_free)

	Steam.lobby_match_list.connect(_on_lobby_match_list)
	refresh()
	first_button.grab_focus()


func call_scene_changer_method(method: StringName) -> void:
	var scene_changer := get_node_or_null(SCENE_CHANGER_PATH)
	if not scene_changer:
		return

	if not scene_changer.has_method(method):
		return

	scene_changer.call(method)


func go_back() -> void:
	call_scene_changer_method(MAIN_MENU_METHOD)


func notify(message: String) -> void:
	notify_dialog.dialog_text = message
	notify_dialog.popup_centered()
	print(message)


func refresh() -> void:
	refresh_button.disabled = DISABLE_WHILE_REFRESHING
	refresh_button.text = REFRESHING_TEXT
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()


func _add_summary_for(lobby_id: int) -> void:
	var summary: LobbySummary = lobby_summary_scene.instantiate()
	summary.lobby_id = lobby_id
	summary.join_pressed.connect(
			func() -> void: join_lobby_requested.emit(lobby_id)
	)
	summary_container.add_child(summary)


func _get_lobby_ids_without_summaries(lobby_ids: Array[int]) -> Array[int]:
	var ids_with_summaries: Array[int] = []
	for summary: LobbySummary in summary_container.get_children():
		ids_with_summaries.append(summary.lobby_id)

	var ids_without_summaries: Array[int] = []
	for lobby_id in lobby_ids:
		if not ids_with_summaries.has(lobby_id):
			ids_without_summaries.append(lobby_id)

	return ids_without_summaries


func _set_ping_for(summary: LobbySummary) -> void:
	var location_string := Steam.getLobbyData(summary.lobby_id, LOCATION_KEY)
	var parsed: Dictionary = Steam.parsePingLocationString(location_string)
	if not parsed.get(PARSED_SUCCESS_KEY, PARSED_SUCCESS_DEFAULT):
		return

	var location: Array = parsed.get(PARSED_LOCATION_KEY, [])
	var ping: int = Steam.estimatePingTimeFromLocalHost(location)
	if ping < 0:
		return

	summary.ping = ping


func _on_lobby_created() -> void:
	# Set up host's player like any other.
	multiplayer.peer_connected.emit(multiplayer.get_unique_id())
	call_scene_changer_method(LOBBY_METHOD)


# The game will crash if the user cancels in the middle of joining a Steam
# lobby. _on_lobby_joined avoids that crash by not allowing canceling.
func _on_lobby_joined() -> void:
	joining_window.popup_centered()
	await get_tree().create_timer(JOIN_TIMEOUT_SEC).timeout
	notify(JOIN_FAILED_MESSAGE)


func _on_lobby_match_list(untyped_lobby_ids: Array) -> void:
	var lobby_ids: Array[int] = []
	lobby_ids.assign(untyped_lobby_ids)

	for lobby_id in _get_lobby_ids_without_summaries(lobby_ids):
		_add_summary_for(lobby_id)

	for summary: LobbySummary in summary_container.get_children():
		var lobby_id := summary.lobby_id
		if lobby_id not in lobby_ids:
			summary.queue_free()
			continue

		summary.lobby_name = Steam.getLobbyData(lobby_id, NAME_KEY)

		# TODO: Get lobby type.

		summary.player_count = Steam.getNumLobbyMembers(lobby_id)
		summary.player_limit = Steam.getLobbyMemberLimit(lobby_id)
		_set_ping_for(summary)

	refresh_button.disabled = DISABLE_WHILE_NOT_REFRESHING
	refresh_button.text = REFRESH_TEXT
