extends StateComponent


@export var target_node: Node
@export var property_name: StringName
@export var invert := false


func _on_state_entered() -> void:
	target_node.set(property_name, not invert)


func _on_state_exited() -> void:
	target_node.set(property_name, invert)
