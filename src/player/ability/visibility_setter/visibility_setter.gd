extends Ability


@export var target_node: Node


func _on_player_state_machine_transitioned(state_name: String) -> void:
	target_node.visible = state_name in _state_names
