extends Node

signal health_emptied
signal health_filled
signal health_percentage_changed(value: float)

@export var health_time := 10

## If true, health can be added or subtracted only once per physics tick.
@export var once_per_tick := true

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

var _locked := false:
	set = _set_locked


func _physics_process(_delta: float) -> void:
	_locked = false


func add_health(value: int) -> void:
	if _locked:
		return

	health += value
	_locked = once_per_tick


func subtract_health(value: int) -> void:
	add_health(-value)


func _set_locked(value: bool) -> void:
	_locked = value
	set_physics_process(_locked)
