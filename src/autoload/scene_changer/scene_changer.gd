extends Node

@export var lobby: PackedScene
@export var lobby_browser: PackedScene
@export var main_menu: PackedScene
@export var ghost_tutorial: PackedScene
@export var hunter_tutorial: PackedScene

@onready var disconnected_dialog: AcceptDialog = $DisconnectedDialog
@onready var scene_spawner: MultiplayerSpawner = $SceneSpawner


func _ready() -> void:
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	Steam.join_requested.connect(_on_join_requested)


func change_scene_to_node(node: Node) -> void:
	if not multiplayer.is_server():
		return

	remove_scene()
	scene_spawner.add_child(node, true)
	get_tree().set_pause(false)


func change_scene_to_packed(packed_scene: PackedScene) -> void:
	change_scene_to_node(packed_scene.instantiate())


func change_to_lobby() -> void:
	change_scene_to_packed(lobby)


func change_to_lobby_browser() -> void:
	change_scene_to_packed(lobby_browser)


func change_to_main_menu() -> void:
	change_scene_to_packed(main_menu)


func change_to_ghost_tutorial() -> void:
	change_scene_to_packed(ghost_tutorial)


func change_to_hunter_tutorial() -> void:
	change_scene_to_packed(hunter_tutorial)


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


# Resets multiplayer peer and returns to
# main menu if there isn't a spawned scene.
func _main_menu_fallback() -> void:
	if scene_spawner.get_child_count() > 0:
		return

	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	change_to_main_menu()


func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	disconnected_dialog.popup_centered()
	change_scene_to_packed(main_menu)


func _on_join_requested(lobby_id: int, _steam_id: int) -> void:
	join_lobby(lobby_id)
