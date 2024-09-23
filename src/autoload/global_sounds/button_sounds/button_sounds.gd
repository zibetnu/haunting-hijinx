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
	var button_signal: Signal = button.pressed
	var receiver: Callable = _audio_stream_player.play
	if button_signal.is_connected(receiver):
		return

	button_signal.connect(receiver)
