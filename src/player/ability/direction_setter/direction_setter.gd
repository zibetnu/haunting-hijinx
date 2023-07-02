extends Ability


const THRESHOLD = PI / 8

@export var source_node: Node
@export var source_variable: String

var _last_source_vector := Vector2.DOWN


func _physics_process(_delta: float) -> void:
	var source_vector: Vector2 = source_node.get(source_variable)
	if source_vector.is_zero_approx():
		return

	if abs(source_vector.angle_to(_last_source_vector)) < THRESHOLD:
		return

	_last_source_vector = source_vector
	player.costume.direction_vector = source_vector


func _on_player_state_machine_transitioned(state_name: String) -> void:
	set_physics_process(state_name in _state_names)
