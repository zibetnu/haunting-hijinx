class_name Spotlight
extends ColorRect

const POSITION_PARAMETER = &"circle_position"
const SIZE_PARAMETER = &"circle_size"
const WIDTH_PARAMETER = &"screen_width"
const HEIGHT_PARAMETER = &"screen_height"

@export var focus_on: CanvasItem:
	set = set_focus_on
@export_range(0.0, 1.0, 0.001) var spotlight_size := 0.5:
	set = set_spotlight_size

@onready var _base_viewport_width: int = ProjectSettings.get_setting(
		"display/window/size/viewport_width"
)
@onready var _shader_material: ShaderMaterial = material
@onready var _window: Window = get_window()


func _ready() -> void:
	_window.size_changed.connect(_on_window_size_changed)


func set_focus_on(value: CanvasItem) -> void:
	var callable: Callable = _update_position
	if focus_on and focus_on.item_rect_changed.is_connected(callable):
		focus_on.item_rect_changed.disconnect(callable)

	focus_on = value
	if focus_on and not focus_on.item_rect_changed.is_connected(callable):
		focus_on.item_rect_changed.connect(callable)


func set_spotlight_size(value: float) -> void:
	spotlight_size = value
	_update_position()
	_update_size()


func _update_position() -> void:
	if focus_on == null:
		return

	_shader_material.set_shader_parameter(
		POSITION_PARAMETER,
		focus_on.get_global_transform_with_canvas().origin / size
	)


func _update_size() -> void:
	_shader_material.set_shader_parameter(
			SIZE_PARAMETER,
			(_base_viewport_width * spotlight_size) / size.y
	)


func _on_window_size_changed() -> void:
	_shader_material.set_shader_parameter(WIDTH_PARAMETER, size.x)
	_shader_material.set_shader_parameter(HEIGHT_PARAMETER, size.y)
	_update_size()
