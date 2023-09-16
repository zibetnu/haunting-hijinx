extends Item


@export var weak_to: DamageSource.Type


func _ready() -> void:
	$AnimationPlayer.play("spawn")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("bob")


func take_damage(source: DamageSource) -> void:
	if source.damage_type != weak_to:
		return

	$AnimationPlayer.play("destroy")
	if not multiplayer.is_server():
		return

	$CollisionShape2D.disabled = true
	await $AnimationPlayer.animation_finished
	queue_free()


func _acquirer_allowed(acquirer: Variant) -> bool:
	return "percentage" in acquirer and acquirer.percentage < 0.9


func _on_acquired(acquirer: Variant) -> void:
	acquirer.percentage = 1
