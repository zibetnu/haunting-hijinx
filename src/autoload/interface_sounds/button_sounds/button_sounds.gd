extends Node


@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if not node is Button:
		return

	if not is_node_ready():
		await ready

	if not node.is_node_ready():
		await node.ready

	var button: Button = node
	button.pressed.connect(_audio_stream_player.play)
