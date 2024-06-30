extends Area2D


@export var weak_to: DamageSource.Type


func _ready() -> void:
	$AnimationPlayer.play("spawn")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("bob")


@rpc("call_local")
func destoy() -> void:
	$AnimationPlayer.play("destroy")
	$CollisionShape2D.disabled = true
	await $AnimationPlayer.animation_finished
	if multiplayer.is_server():
		queue_free()


func take_damage(source: DamageSource) -> void:
	if source.damage_type != weak_to:
		return

	if multiplayer.is_server():
		destoy.rpc()


func _acquirer_allowed(acquirer: Variant) -> bool:
	if not "battery_percentage" in acquirer:
		return false

	return true


func _on_acquired(acquirer: Variant) -> void:
	acquirer.battery_percentage = 1


func _on_entered(acquirer: Variant) -> void:
	if not _acquirer_allowed(acquirer):
		return

	if not multiplayer.is_server():
		return

	_on_acquired(acquirer)
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	_on_entered(area)


func _on_body_entered(body: Node2D) -> void:
	_on_entered(body)
