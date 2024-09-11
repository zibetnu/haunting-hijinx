extends Node


@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	var button := node as Button
	if button == null:
		return

	button.pressed.connect(_audio_stream_player.play)
