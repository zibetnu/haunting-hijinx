extends Node2D


enum Mode {
	IDLE,
	ACTIVE,
}

const ACTIVE_PARAMETERS = {
	"amplitude": 2,
	"frequency": 4,
	"ripple_rate": 12,
}
const IDLE_PARAMETERS = {
	"amplitude": 1,
	"frequency": -4,
	"ripple_rate": 6,
}

@export var mode: Mode:
	set = set_mode

@onready var _waves_material: ShaderMaterial = ($Waves as ColorRect).material


func _ready() -> void:
	set_idle()


func set_active() -> void:
	set_mode(Mode.ACTIVE)


func set_idle() -> void:
	set_mode(Mode.IDLE)


func set_mode(value: Mode) -> void:
	mode = value
	match mode:
		Mode.IDLE:
			_set_parameters_from_dictionary(IDLE_PARAMETERS)

		Mode.ACTIVE:
			_set_parameters_from_dictionary(ACTIVE_PARAMETERS)


func _set_parameters_from_dictionary(parameters: Dictionary) -> void:
	for key: String in parameters:
		_waves_material.set_shader_parameter(key, parameters[key])
