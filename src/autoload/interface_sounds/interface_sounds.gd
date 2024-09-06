extends Node


@onready var pressed: AudioStreamPlayer = $Pressed
@onready var signal_to_player: Dictionary = {
	&"pressed": pressed,
	&"drag_started": pressed,
}


func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if not node is Control:
		return

	for signal_name: StringName in signal_to_player:
		if not node.has_signal(signal_name):
			continue

		var player: AudioStreamPlayer = signal_to_player[signal_name]
		node.connect(signal_name, player.play)
