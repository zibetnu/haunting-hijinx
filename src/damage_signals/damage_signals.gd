extends Area2D

signal damaged_by_amount(damage_amount: int)
signal damaged_by(source: DamageSource)
signal damage_taken

@export var weak_to: DamageSource.Type


func take_damage(source: DamageSource) -> void:
	if source.damage_type != weak_to:
		return

	damaged_by.emit(source)
	damaged_by_amount.emit(source.damage_amount)
	damage_taken.emit()
