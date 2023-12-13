class_name DamageSource
extends Resource


enum Type {
	DARK,
	LIGHT,
	SPECTRAL,
}

@export var damage_amount: int
@export var damage_type: Type


static func from_dark(damage: int = 0) -> DamageSource:
	var source := DamageSource.new()
	source.damage_type = Type.DARK
	source.damage_amount = damage
	return source


static func from_light(damage: int = 0) -> DamageSource:
	var source := DamageSource.new()
	source.damage_type = Type.LIGHT
	source.damage_amount = damage
	return source


static func from_spectral(damage: int = 0) -> DamageSource:
	var source := DamageSource.new()
	source.damage_type = Type.SPECTRAL
	source.damage_amount = damage
	return source
