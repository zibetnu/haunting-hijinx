extends Node

const CONNECT_LOBBY_COMMAND = "+connect_lobby"
const NOT_FOUND_INDEX = -1
const COMMAND_INDEX_OFFSET = 1
const MIN_LOBBY_ID = 1
const PLACEHOLDER_LOBBY_ID = -1

@export var start_scene: PackedScene


func _ready() -> void:
	Steam.steamInitEx()
	for bus_index in AudioServer.bus_count:
		init_bus_volume(bus_index)

	var lobby_id: int = get_lobby_id_from_arguments()
	if lobby_id == PLACEHOLDER_LOBBY_ID:
		SceneChanger.change_scene_to_packed(start_scene)

	else:
		SceneChanger.join_lobby(lobby_id)

	queue_free()


func get_lobby_id_from_arguments() -> int:
	var arguments: Array[String] = []
	arguments.assign(OS.get_cmdline_args())

	var command_index: int = arguments.find(CONNECT_LOBBY_COMMAND)
	if command_index == NOT_FOUND_INDEX:
		return PLACEHOLDER_LOBBY_ID

	var lobby_id_index: int = command_index + COMMAND_INDEX_OFFSET
	if lobby_id_index >= arguments.size():
		return PLACEHOLDER_LOBBY_ID

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
