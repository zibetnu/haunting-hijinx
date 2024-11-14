extends Node

signal health_emptied
signal health_filled
signal health_percentage_changed(value: float)

@export var health_time := 10

var health := max_health:
	set(value):
		if health > 0 and value == 0:
			health_emptied.emit()

		if health < max_health and value >= max_health:
			health_filled.emit()

		health = clampi(value, 0, max_health)
		health_percentage_changed.emit(health / float(max_health))

var max_health: int:
	get:
		return (
				health_time
				* ProjectSettings.get_setting(
						"physics/common/physics_ticks_per_second"
				)
		)


func add_health(value: int) -> void:
	health += value


func subtract_health(value: int) -> void:
	health -= value
