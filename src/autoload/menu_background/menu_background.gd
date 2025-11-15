extends CanvasItem

@export var scene_names: Array[StringName]

@onready var level_layers: LevelTileMapLayers = %LevelTileMapLayers


func _ready() -> void:
	@warning_ignore("unsafe_method_access", "unsafe_property_access")
	SceneChanger.scene_changed.connect(_on_scene_changed)


func _on_scene_changed(scene_root: Node) -> void:
	var level_shown: bool = visible and level_layers.level != null
	match [level_shown, scene_root.name in scene_names]:
		[false, true]:
			level_layers.level = PeerData.levels.pick_random()
			level_layers.position = level_layers.level.get_limits_center() * -1
			show()

		[true, false]:
			hide()
			level_layers.level = null
