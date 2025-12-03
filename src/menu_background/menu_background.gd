extends CanvasLayer

@export_enum("Selected", "Random") var mode: int

@onready var level_layers: LevelTileMapLayers = %LevelTileMapLayers


func _ready() -> void:
	if mode == 0:
		set_level(PeerData.get_selected_level())
		PeerData.selected_level_changed.connect(set_level)

	else:
		set_level(PeerData.levels.pick_random() as Level)


func set_level(value: Level) -> void:
	level_layers.level = value
	if value == null:
		hide()

	else:
		level_layers.position = level_layers.level.get_limits_center() * -1
		show()
