extends StateComponent


@export var summon: Summon


func _on_state_entered() -> void:
	summon.charging = true


func _on_state_exited() -> void:
	summon.charging = false
	summon.charge = 0
