extends Node
## Plays sound for signals emitted by various buttons.

const EXCLUDE_GROUP_NAME = &"exclude_button_sounds"

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var signals_to_callables: Dictionary = {
	&"item_activated": audio_stream_player.play,
	&"pressed": audio_stream_player.play,
	&"pressed_sound_requested": audio_stream_player.play,
	&"tab_selected": func(_tab: int) -> void: audio_stream_player.play(),
}


func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if node.owner == null:
		return

	if node.is_in_group(EXCLUDE_GROUP_NAME):
		return

	if not is_node_ready():
		await ready

	for signal_name: StringName in signals_to_callables:
		if not node.has_signal(signal_name):
			continue

		var callable: Callable = signals_to_callables[signal_name]
		if node.is_connected(signal_name, callable):
			continue

		node.connect(signal_name, callable)
