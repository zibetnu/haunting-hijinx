extends Area2D


signal sensed_intensity_changed(intensity: int)

@export var active := true:
	set(value):
		active = value
		_update_sensed_intensity()

var sensed_intensity: int:
	set(value):
		sensed_intensity = value
		sensed_intensity_changed.emit(value)

var _sensed_auras: Array[Node] = []


func add_aura(source: Node) -> void:
	if not "intensity" in source:
		return

	if source in _sensed_auras:
		return

	_sensed_auras.append(source)
	_update_sensed_intensity()


func remove_aura(source: Node) -> void:
	if not source in _sensed_auras:
		return

	_sensed_auras.erase(source)
	_update_sensed_intensity()


func _update_sensed_intensity() -> void:
	if active and _sensed_auras.size() > 0:
		_sensed_auras.sort_custom(func(a, b): return a.intensity > b.intensity)
		sensed_intensity = _sensed_auras[0].intensity

	else:
		sensed_intensity = 0
