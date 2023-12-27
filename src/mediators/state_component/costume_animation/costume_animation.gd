extends StateComponent


@export var animation_name: String
@export var costume_behavior: CostumeBehavior


func _on_state_entered() -> void:
	costume_behavior.animation_name = animation_name
