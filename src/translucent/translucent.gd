extends Node

@export var target: CanvasItem
@export var enabled := false:
	set(value):
		enabled = value
		target.modulate.a = enabled_value if enabled else disabled_value

@export_range(0, 1) var enabled_value := 0.5
@export_range(0, 1) var disabled_value := 1.0


func disable_translucency() -> void:
	enabled = false


func enable_translucency() -> void:
	enabled = true
