extends Item


func _ready() -> void:
	$AnimationPlayer.play("spawn")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("bob")


func _acquirer_allowed(acquirer: Variant) -> bool:
	return (
			"battery" in acquirer
			and "max_battery" in acquirer
			and acquirer.battery < acquirer.max_battery
	)


func _on_acquired(acquirer: Variant) -> void:
	acquirer.battery = acquirer.max_battery
