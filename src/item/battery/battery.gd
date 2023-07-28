extends Item


func _ready() -> void:
	$AnimationPlayer.play("spawn")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("bob")


func _acquirer_allowed(acquirer: Variant) -> bool:
	return "percentage" in acquirer and acquirer.percentage < 0.9


func _on_acquired(acquirer: Variant) -> void:
	acquirer.percentage = 1
