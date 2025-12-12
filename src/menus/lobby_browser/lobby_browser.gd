class_name LobbyBrowser
extends Menu

signal back_pressed
signal join_lobby_requested(lobby_id: int)
signal refreshed

const REFRESH_TEXT = "Refresh"
const DISABLE_WHILE_NOT_REFRESHING = false

const REFRESHING_TEXT = "Refreshing..."
const DISABLE_WHILE_REFRESHING = true

const ID_KEY = "id"
const LOBBY_KEY = "lobby"
const PRIVATE_LOBBY_ID = 0

const NAME_KEY = "name"
const TYPE_KEY = "type"

const LOCATION_KEY = "location"
const PARSED_SUCCESS_KEY = "success"
const PARSED_SUCCESS_DEFAULT = false
const PARSED_LOCATION_KEY = "ping_location"

const JOIN_TIMEOUT_SEC = 15.0
const JOIN_FAILED_MESSAGE = "Failed to join lobby. Try restarting the game."

const SCENE_CHANGER_PATH = ^"/root/SceneChanger"
const LOBBY_METHOD = &"change_to_lobby"
const MAIN_MENU_METHOD = &"change_to_main_menu"

const LOCAL_PORT = 9999

@export var lobby_summary_scene: PackedScene

@onready var joining_window: Window = %JoiningWindow
@onready var summary_container: VBoxContainer = %LobbySummaries
@onready var notify_dialog: AcceptDialog = %NotifyDialog
@onready var refresh_button: Button = %Refresh
@onready var host_local: Button = %HostLocal
@onready var join_local: Button = %JoinLocal
@onready var init_steam: Button = %InitSteam
@onready var steam_connector: SteamConnector = $SteamConnector


func _ready() -> void:
	super()
	join_lobby_requested.connect(_on_join_lobby_requested)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	steam_connector.close_connection.call_deferred()
	if OS.has_feature("editor"):
		host_local.show()
		join_local.show()
		init_steam.show()

	else:
		init_steam_relay()


func call_scene_changer_method(method: StringName) -> void:
	var scene_changer := get_node_or_null(SCENE_CHANGER_PATH)
	if not scene_changer:
		return

	if not scene_changer.has_method(method):
		return

	scene_changer.call(method)


func init_steam_relay() -> void:
	Steam.steamInitEx()
	Steam.initRelayNetworkAccess()


func is_relay_ready(action: String) -> bool:
	var result: Dictionary = Steam.get_steam_init_result()
	if result.get("status", 1) != 0:
		print("Initialize Steam before %s" % action)
		return false

	if Steam.getRelayNetworkStatus() != Steam.NETWORKING_AVAILABILITY_CURRENT:
		print("Wait for relay to initialize")
		return false

	return true


func notify(message: String) -> void:
	notify_dialog.dialog_text = message
	notify_dialog.popup_centered()
	print(message)


func refresh() -> void:
	if not is_relay_ready("refreshing lobby list"):
		return

	refresh_button.disabled = DISABLE_WHILE_REFRESHING
	refresh_button.text = REFRESHING_TEXT
	Steam.addRequestLobbyListDistanceFilter(
			Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE
	)
	Steam.requestLobbyList()
	_get_friend_lobby_ids().map(Steam.requestLobbyData)


func _add_summary_for(lobby_id: int) -> void:
	var summary: LobbySummary = lobby_summary_scene.instantiate()
	summary.lobby_id = lobby_id
	summary.pressed.connect(
			func() -> void: join_lobby_requested.emit(lobby_id)
	)
	summary_container.add_child(summary)


func _get_friend_lobby_ids() -> Array[int]:
	var friend_lobby_ids: Array[int] = []
	for friend_index in range(Steam.getFriendCount()):
		var friend_steam_id: int = Steam.getFriendByIndex(
				friend_index, Steam.FRIEND_FLAG_IMMEDIATE
		)
		var game_info: Dictionary = Steam.getFriendGamePlayed(friend_steam_id)
		if game_info.is_empty():
			continue

		if game_info[ID_KEY] != Steam.getAppID():
			continue

		var lobby_id: Variant = game_info[LOBBY_KEY]
		if not lobby_id is int:
			continue

		if lobby_id == PRIVATE_LOBBY_ID:
			continue

		friend_lobby_ids.append(lobby_id)

	return friend_lobby_ids


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


func _on_init_steam_pressed() -> void:
	init_steam_relay()


func _on_lobby_created() -> void:
	PeerData.erase_data()
	PeerData.init_peer(1, GameConfig.customization.get_as_dict())
	call_scene_changer_method(LOBBY_METHOD)


func _on_join_lobby_requested(_id: int) -> void:
	joining_window.popup_centered()
	await get_tree().create_timer(JOIN_TIMEOUT_SEC).timeout
	notify(JOIN_FAILED_MESSAGE)


func _on_lobby_match_list(untyped_lobby_ids: Array) -> void:
	var lobby_ids: Array[int] = []
	lobby_ids.assign(untyped_lobby_ids)
	for lobby_id in _get_friend_lobby_ids():
		if lobby_id in lobby_ids:
			continue

		lobby_ids.append(lobby_id)

	lobby_ids.filter(Steam.isLobby)
	lobby_ids.filter(
			func(lobby_id: int) -> bool:
				return Steam.getLobbyMemberLimit(lobby_id) > 0
	)
	for lobby_id in _get_lobby_ids_without_summaries(lobby_ids):
		_add_summary_for(lobby_id)

	for summary: LobbySummary in summary_container.get_children():
		var lobby_id := summary.lobby_id
		if lobby_id not in lobby_ids:
			summary.queue_free()
			continue

		summary.lobby_name = Steam.getLobbyData(lobby_id, NAME_KEY)
		summary.lobby_type = Steam.getLobbyData(lobby_id, TYPE_KEY)
		summary.player_count = Steam.getNumLobbyMembers(lobby_id)
		summary.player_limit = Steam.getLobbyMemberLimit(lobby_id)
		_set_ping_for(summary)

	refresh_button.disabled = DISABLE_WHILE_NOT_REFRESHING
	refresh_button.text = REFRESH_TEXT
	refreshed.emit()


func _on_create_lobby_pressed() -> void:
	if not is_relay_ready("creating lobby"):
		return

	steam_connector.create_lobby()


func _on_host_local_pressed() -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(LOCAL_PORT)
	multiplayer.multiplayer_peer = peer
	_on_lobby_created()


func _on_join_local_pressed() -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_client("localhost", LOCAL_PORT)
	multiplayer.multiplayer_peer = peer


func _on_back_pressed() -> void:
	back_pressed.emit()
