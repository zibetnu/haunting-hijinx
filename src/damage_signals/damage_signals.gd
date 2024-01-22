extends Area2D


signal damaged_by(source: DamageSource)
signal damage_taken


func take_damage(source: DamageSource) -> void:
	damaged_by.emit(source)
	damage_taken.emit()
