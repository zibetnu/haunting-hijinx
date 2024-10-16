extends Node


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if not node is Tree:
		return

	if not is_node_ready():
		await ready

	if not node.is_node_ready():
		await node.ready

	var tree: Tree = node
	var tree_signal: Signal = tree.item_activated
	var receiver: Callable = audio_stream_player.play
	if tree_signal.is_connected(receiver):
		return

	tree_signal.connect(receiver)
