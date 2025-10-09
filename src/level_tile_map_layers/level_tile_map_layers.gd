@tool
class_name LevelTileMapLayers
extends Node2D

@export var level: Level:
	set = set_level

@export_group("Level Editing", "edit")
@export var edit_level_name: String
@export var edit_level_file_name: String

@onready var level_lighting: LevelLighting = $LevelLighting
@onready var layers: Array[TileMapLayer] = [
	$FloorLayer,
	$WallLayer,
	$WallTopLayer,
	$WallCapLayer,
	$PropLayer,
]
@onready var editor_nodes: CanvasLayer = %EditorNodes
@onready var ghost_spawn_marker: Marker2D = %GhostSpawnMarker
@onready var hunter_spawn_markers: Array[Marker2D] = [
	%HunterSpawnMarker,
	%HunterSpawnMarker2,
	%HunterSpawnMarker3,
	%HunterSpawnMarker4
]
@onready var camera_limit_top_left: Marker2D = %CameraLimitTopLeft
@onready var camera_limit_bottom_right: Marker2D = %CameraLimitBottomRight


func _ready() -> void:
	editor_nodes.visible = Engine.is_editor_hint()
	refresh()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_EDITOR_PRE_SAVE:
			save_level()


func refresh() -> void:
	if level == null:
		edit_level_name = ""
		edit_level_file_name = ""
		for layer in layers:
			layer.clear()

		for child: Node2D in editor_nodes.get_children():
			child.position = Vector2.ZERO

		return

	edit_level_name = level.resource_name
	edit_level_file_name = level.resource_path.get_file()
	ghost_spawn_marker.position = level.ghost_spawn_point
	if not level.hunter_spawn_points.is_empty():
		for i in level.hunter_spawn_points.size():
			hunter_spawn_markers[i].position = level.hunter_spawn_points[i]

	camera_limit_top_left.position = level.limit_top_left
	camera_limit_bottom_right.position = level.limit_bottom_right
	var layer_data: Array[PackedByteArray] = [
		level.floor_data,
		level.wall_data,
		level.wall_top_data,
		level.wall_cap_data,
		level.prop_data
	]
	for i in layers.size():
		layers[i].tile_map_data = layer_data[i]


func set_level(value: Level) -> void:
	level = value
	if is_node_ready():
		refresh()


func save_level() -> void:
	if level == null:
		toast("No level to save.")
		return

	level.resource_name = edit_level_name
	level.resource_path = "res://src/level/".path_join(edit_level_file_name)

	level.ghost_spawn_point = ghost_spawn_marker.position
	level.hunter_spawn_points.clear()
	for marker in hunter_spawn_markers:
		level.hunter_spawn_points.append(marker.position)

	level.limit_top_left = camera_limit_top_left.position
	level.limit_bottom_right = camera_limit_bottom_right.position

	var data_properties: Array[StringName] = [
		&"floor_data",
		&"wall_data",
		&"wall_top_data",
		&"wall_cap_data",
		&"prop_data",
	]
	for i in data_properties.size():
		level.set(data_properties[i], layers[i].tile_map_data)

	if level.resource_path.is_empty():
		toast("Set the file name to save properly.")

	else:
		toast("Changes saved.")
		ResourceSaver.save(level)


func toast(message: String) -> void:
	if not Engine.is_editor_hint():
		return

	var editor_interface: Object = Engine.get_singleton(&"EditorInterface")
	@warning_ignore("unsafe_method_access")
	editor_interface.get_editor_toaster().push_toast(message)
