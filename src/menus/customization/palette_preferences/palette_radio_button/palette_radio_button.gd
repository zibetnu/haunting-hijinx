class_name PaletteRadioButton
extends TextureButton

@export var palette: Texture2D:
	set = set_palette


func _ready() -> void:
	_apply_palette()


func set_palette(value: Texture2D) -> void:
	palette = value
	if is_node_ready():
		_apply_palette()


func _apply_palette() -> void:
	(material as ShaderMaterial).set_shader_parameter(&"new_palette", palette)
