class_name Main
extends Node

const PLACEHOLDER_LOBBY_ID = -1

@export var start_scene: PackedScene

@onready var godot_splash_screen: GodotSplashScreen = $GodotSplashScreen


func _ready() -> void:
	# Ensure that data is only shared between clients when necessary.
	(multiplayer as SceneMultiplayer).server_relay = false
	for bus_index in AudioServer.bus_count:
		init_bus_volume(bus_index)

	var lobby_id: int = get_lobby_id_from_arguments()
	if lobby_id != PLACEHOLDER_LOBBY_ID:
		SceneChanger.join_lobby(lobby_id)
		queue_free()
		return

	if OS.has_feature("editor"):
		print("Steam not initialized")

	else:
		Steam.steamInitEx()

	godot_splash_screen.start()
	await godot_splash_screen.finished
	SceneChanger.change_scene_to_packed(start_scene)
	queue_free()


func get_lobby_id_from_arguments() -> int:
	var arguments: Array[String] = []
	arguments.assign(OS.get_cmdline_args())

	var command_index: int = arguments.find("+connect_lobby")
	if command_index == -1:
		return PLACEHOLDER_LOBBY_ID

	var lobby_id_index: int = command_index + 1
	if lobby_id_index >= arguments.size():
		return PLACEHOLDER_LOBBY_ID

	const MIN_LOBBY_ID = 1
	var lobby_id: int = arguments[lobby_id_index].to_int()
	if lobby_id < MIN_LOBBY_ID:
		return PLACEHOLDER_LOBBY_ID

	return lobby_id


func init_bus_volume(bus_index: int) -> void:
	var bus_volume_linear: float = GameConfig.get_value(
			"audio",
			AudioServer.get_bus_name(bus_index).to_snake_case(),
			-1.0
	)
	if bus_volume_linear < 0.0:
		return

	AudioServer.set_bus_volume_db(bus_index, linear_to_db(bus_volume_linear))
