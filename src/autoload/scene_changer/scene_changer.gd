extends Node


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


func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	disconnected_dialog.popup_centered()
	change_scene_to_packed(main_menu)
