extends CanvasItem


@export var scene_names: Array[StringName]

var _scenes_present := 0:
	set=_set_scenes_present


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)


func _set_scenes_present(value: int) -> void:
	_scenes_present = value
	visible = _scenes_present > 0


func _on_node_added(node: Node) -> void:
	if not node.name in scene_names:
		return

	_scenes_present += 1
	node.tree_exiting.connect(func() -> void: _scenes_present -= 1)
