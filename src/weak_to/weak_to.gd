extends Node


signal damaged_by(source: DamageSource)
signal damage_taken

@export var weak_to: DamageSource.Type


func take_damage(source: DamageSource) -> void:
	if source.damage_type != weak_to:
		return

	damaged_by.emit(source)
	damage_taken.emit()
