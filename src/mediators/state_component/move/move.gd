extends StateComponent


@export var controller: Controller
@export var player: Player
@export var speed := 128.0


func _on_state_physics_processing(_delta: float) -> void:
	player.velocity = controller.move_vector.normalized() * speed
	player.move_and_slide()
