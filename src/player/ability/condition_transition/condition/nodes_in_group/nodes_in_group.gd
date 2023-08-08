extends Condition


@export var group: String
@export var invert := false


func is_true() -> bool:
	var group_has_nodes := get_tree().get_nodes_in_group(group).size() > 0
	return (group_has_nodes and not invert) or (not group_has_nodes and invert)
