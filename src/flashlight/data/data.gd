class_name FlashlightData
extends Node


signal changed()

@export var flashlight_turn_speed := 2 * PI:
	set(value):
		if flashlight_turn_speed == value:
			return

		flashlight_turn_speed = value
		changed.emit()

@export_group("Collision", "collision")
@export var collision_cast_length := 0.0:
	set(value):
		if collision_cast_length == value:
			return

		collision_cast_length = value
		changed.emit()

@export var collision_points: Array[Vector2] = []

@export_group("Damage", "damage")
@export var damage_deals: DamageSource:
	set(value):
		if damage_deals == value:
			return

		damage_deals = value
		changed.emit()

@export var damage_weak_to: DamageSource.Type:
	set(value):
		if damage_weak_to == value:
			return

		damage_weak_to = value
		changed.emit()


func set_collision_points(points: Array[Vector2]) -> void:
	if collision_points == points:
		return

	collision_points = points
	changed.emit()
