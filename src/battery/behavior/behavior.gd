extends Area2D


signal acquired
signal disabled

const ACQUIRER_PROPERTY = &"battery_percentage"
const ACQUIRER_VALUE = 1.0

@export var weak_to: DamageSource.Type

@onready var _collision_shape_2d: CollisionShape2D = $CollisionShape2D


func acquire(acquirer: Object) -> void:
	if not ACQUIRER_PROPERTY in acquirer:
		return

	acquirer.set(ACQUIRER_PROPERTY, ACQUIRER_VALUE)
	acquired.emit()


func disable() -> void:
	_collision_shape_2d.disabled = true
	disabled.emit()


func take_damage(source: DamageSource) -> void:
	if source.damage_type != weak_to:
		return

	disable()
