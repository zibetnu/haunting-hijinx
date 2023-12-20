extends StateComponent


@export var controller: Controller
@export var character: CharacterBody2D
@export var speed := 128.0


func _on_state_physics_processing(_delta: float) -> void:
	character.velocity = controller.move_vector.normalized() * speed
	character.move_and_slide()
