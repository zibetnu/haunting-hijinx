extends Sprite2D


@export var source_node: Node
@export var progress_variable: String
@export var total_variable: String


func _ready() -> void:
	set_process(
			source_node != null
			and source_node.get(progress_variable) != null
			and source_node.get(total_variable) != null
	)


func _process(_delta: float) -> void:
	material.set_shader_parameter(
			"percentage",
			float(source_node.get(progress_variable)) / source_node.get(total_variable)
	)
