extends Node


const DRAIN_AREA_GROUP_NAME = &"drain_area_displays"
const ACTIVATED_SIGNAL_NAME = &"active_started"

@onready var spawn: AudioStreamPlayer = $Spawn
@onready var activate: AudioStreamPlayer = $Activate


func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)


func _on_activated() -> void:
	if activate.is_playing():
		return

	activate.play()


func _on_spawned() -> void:
	if spawn.is_playing():
		return

	spawn.play()


func _on_node_added(node: Node) -> void:
	if not node.is_in_group(DRAIN_AREA_GROUP_NAME):
		return

	if not is_node_ready():
		await ready

	if not node.is_node_ready():
		await node.ready

	_on_spawned()
	node.connect(ACTIVATED_SIGNAL_NAME, _on_activated)
