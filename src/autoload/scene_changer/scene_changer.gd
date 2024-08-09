extends Node


@export var config_menu: PackedScene
@export var lobby: PackedScene
@export var lobby_browser: PackedScene
@export var main_menu: PackedScene

@onready var disconnected_dialog: AcceptDialog = $DisconnectedDialog
@onready var scene_spawner: MultiplayerSpawner = $SceneSpawner


func _ready() -> void:
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func change_scene_to_packed(packed_scene: PackedScene) -> void:
	remove_scene()
	if not multiplayer.is_server():
		return

	scene_spawner.add_child(packed_scene.instantiate(), true)
	get_tree().set_pause(false)


func change_to_config_menu() -> void:
	change_scene_to_packed(config_menu)


func change_to_lobby() -> void:
	change_scene_to_packed(lobby)


func change_to_lobby_browser() -> void:
	change_scene_to_packed(lobby_browser)


func change_to_main_menu() -> void:
	change_scene_to_packed(main_menu)


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
