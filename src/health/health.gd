extends Node


signal health_zeroed
signal health_maxed


@export var health_time := 10

var health := max_health:
	set(value):
		if health > 0 and value == 0:
			health_zeroed.emit()

		if health < max_health and value >= max_health:
			health_maxed.emit()

		health = clampi(value, 0, max_health)

var max_health: int:
	get:
		return (health_time
				* ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))


func add_health(value: int) -> void:
	health += value


func subtract_health(value: int) -> void:
	health -= value
