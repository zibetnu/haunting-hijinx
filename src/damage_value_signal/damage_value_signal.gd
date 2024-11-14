extends Node

signal damaged_by_amount(damage_amount: int)


func take_damage(source: DamageSource) -> void:
	damaged_by_amount.emit(source.damage_amount)
