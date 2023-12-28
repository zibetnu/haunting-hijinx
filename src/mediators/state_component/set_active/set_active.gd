extends StateComponent


@export var target: Node


func _on_state_entered() -> void:
	target.set("active", true)


func _on_state_exited() -> void:
	target.set("active", false)
