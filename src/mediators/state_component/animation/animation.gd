extends StateComponent


@export var animation_player: AnimationPlayer
@export var animation_name: StringName


func _on_state_entered() -> void:
	animation_player.play(animation_name)
