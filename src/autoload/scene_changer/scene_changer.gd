extends Node

signal cover_confirmed

const SCENES: Dictionary[StringName, PackedScene] = {
	&"menus": preload("uid://bnoti7vnd7pk7"),
	&"lobby": preload("uid://df63fi5u7xpjt"),
	&"ghost_tutorial": preload("uid://02ri1p0jbqdb"),
	&"hunter_tutorial": preload("uid://dguyyy188ihbi"),
}

var unconfirmed_peers: Array[int]
var queued_node: Node

var _transition_in_progress := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var disconnected_dialog: AcceptDialog = $DisconnectedDialog
@onready var cover_timer: Timer = %CoverTimer
@onready var scene_spawner: MultiplayerSpawner = $SceneSpawner


func _ready() -> void:
	cover_confirmed.connect(_on_cover_confirmed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	Steam.join_requested.connect(_on_join_requested)


@rpc("authority", "call_local", "reliable")
func cover() -> void:
	_transition_in_progress = true
	animation_player.play(&"cover")
	await animation_player.animation_finished
	if not multiplayer.is_server():
		confirm.rpc()


func uncover() -> void:
	animation_player.play(&"uncover")
	await animation_player.animation_finished
	_transition_in_progress = false


func change_scene_to_node(node: Node) -> void:
	if not multiplayer.is_server():
		return

	if _transition_in_progress:
		return

	_transition_in_progress = true
	queued_node = node
	if multiplayer.get_peers().is_empty():
		await cover()
		_on_cover_confirmed()

	else:
		unconfirmed_peers.assign(multiplayer.get_peers())
		cover.rpc()
		cover_timer.start()


func change_scene_to_packed(packed_scene: PackedScene) -> void:
	change_scene_to_node(packed_scene.instantiate())


func change_to_lobby() -> void:
	change_scene_to_packed(SCENES.lobby)


func change_to_lobby_browser() -> void:
	change_to_menus(Menus.Tab.LOBBY_BROWSER)


func change_to_menus(tab := Menus.Tab.MAIN) -> void:
	var instance: Menus = SCENES.menus.instantiate()
	instance.current_tab = tab
	change_scene_to_node(instance)


func change_to_ghost_tutorial() -> void:
	change_scene_to_packed(SCENES.ghost_tutorial)


func change_to_hunter_tutorial() -> void:
	change_scene_to_packed(SCENES.hunter_tutorial)


func change_to_level(level: Level) -> void:
	var level_player: LevelPlayer = preload("uid://2uclu3gf4iyj").instantiate()
	level_player.level = level
	change_scene_to_node(level_player)


func join_lobby(lobby_id: int) -> void:
	change_to_lobby_browser()
	Steam.joinLobby(lobby_id)


func remove_scene() -> void:
	for child in scene_spawner.get_children():
		scene_spawner.remove_child(child)
		child.queue_free()


# Wait for peers to confirm that they have covered the screen.
@rpc("any_peer", "call_remote", "reliable")
func confirm() -> void:
	unconfirmed_peers.erase(multiplayer.get_remote_sender_id())
	if unconfirmed_peers.is_empty():
		cover_confirmed.emit()


func _on_cover_confirmed() -> void:
	cover_timer.stop()
	remove_scene()
	scene_spawner.add_child(queued_node)
	queued_node = null
	uncover()


# Resets multiplayer peer and returns to
# main menu if there isn't a spawned scene.
func _main_menu_fallback() -> void:
	if scene_spawner.get_child_count() > 0:
		return

	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	change_to_menus()


func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	disconnected_dialog.popup_centered()
	change_to_menus()


func _on_join_requested(lobby_id: int, _steam_id: int) -> void:
	join_lobby(lobby_id)


func _on_scene_spawner_spawned(node: Node) -> void:
	for child in scene_spawner.get_children():
		if child != node:
			scene_spawner.remove_child(child)
			child.queue_free()

	uncover()


func _on_cover_timer_timeout() -> void:
	unconfirmed_peers.clear()
	_on_cover_confirmed()
