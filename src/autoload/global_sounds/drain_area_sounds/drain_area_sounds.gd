extends Node


const DRAIN_AREA_GROUP_NAME = &"drain_areas"
const ACTIVATED_SIGNAL_NAME = &"active_started"

@onready var spawn: AudioStreamPlayer = $Spawn
@onready var activate: AudioStreamPlayer = $Activate


func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if not node.is_in_group(DRAIN_AREA_GROUP_NAME):
		return

	if not is_node_ready():
		await ready

	if not node.is_node_ready():
		await node.ready

	spawn.play()
	node.connect(ACTIVATED_SIGNAL_NAME, activate.play)
