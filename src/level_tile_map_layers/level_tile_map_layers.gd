class_name LevelTileMapLayers
extends Node2D

@export var level: Level:
	set = set_level

@onready var layers: Array[TileMapLayer] = [
	$FloorLayer,
	$WallLayer,
	$WallTopLayer,
	$WallCapLayer,
	$PropLayer,
]


func _ready() -> void:
	refresh()


func refresh() -> void:
	if level == null:
		for layer in layers:
			layer.clear()

		return

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
