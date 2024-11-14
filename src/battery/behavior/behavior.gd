extends Area2D

signal acquired
signal destroyed

const ACQUIRER_PROPERTY = &"battery_percentage"
const ACQUIRER_VALUE = 1.0


func acquire(acquirer: Object) -> void:
	if not ACQUIRER_PROPERTY in acquirer:
		return

	acquirer.set(ACQUIRER_PROPERTY, ACQUIRER_VALUE)
	acquired.emit()
	queue_free()


func destroy() -> void:
	destroyed.emit()
	queue_free()
