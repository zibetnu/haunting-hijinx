extends TextureProgressBar


@export var source_node: Node
@export var value_variable: String
@export var max_variable: String


func _ready() -> void:
	set_process(
			source_node != null
			and source_node.get(value_variable) != null
			and source_node.get(max_variable) != null
	)
	max_value = source_node.get(max_variable)


func _process(_delta: float) -> void:
	value = source_node.get(value_variable)
