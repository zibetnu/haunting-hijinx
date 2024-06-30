extends Area2D


signal acquired
signal destroyed

const ACQUIRER_PROPERTY = &"battery_percentage"
const ACQUIRER_VALUE = 1.0

@export var weak_to: DamageSource.Type


func acquire(acquirer: Object) -> void:
	if not ACQUIRER_PROPERTY in acquirer:
		return

	acquirer.set(ACQUIRER_PROPERTY, ACQUIRER_VALUE)
	acquired.emit()
	queue_free()


func destroy() -> void:
	destroyed.emit()
	queue_free()


func take_damage(source: DamageSource) -> void:
	if source.damage_type != weak_to:
		return

	destroy()
