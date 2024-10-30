extends Node
## Plays sound for signals emitted by various buttons.

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var signals_to_callables: Dictionary = {
	&"item_activated": audio_stream_player.play,
	&"pressed": audio_stream_player.play,
}


func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if not is_node_ready():
		await ready

	for signal_name: StringName in signals_to_callables:
		if not node.has_signal(signal_name):
			continue

		var callable: Callable = signals_to_callables[signal_name]
		if node.is_connected(signal_name, callable):
			continue

		node.connect(signal_name, callable)
