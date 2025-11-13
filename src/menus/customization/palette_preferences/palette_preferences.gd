class_name PalettePreferences
extends Control

signal preferred_indexes_changed
signal pressed_palette_index_changed(index: int)

@export var palettes: Array[Texture2D]

var button_group := ButtonGroup.new()
var pressed_palette_index: int:
	set = set_pressed_palette_index

@onready var button_container: ReorderableContainer = %ButtonContainer


func _ready() -> void:
	button_group.pressed.connect(_on_button_group_pressed)
	init_buttons()


func init_buttons() -> void:
	for child in button_container.get_children():
		button_container.remove_child(child)
		child.queue_free()

	for palette in palettes:
		var button: PaletteRadioButton = preload("uid://ddoffvjsqum16").instantiate()
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		button.button_group = button_group
		button.keep_pressed_outside = true
		button.palette = palette
		button_container.add_child(button)

	button_group.get_buttons()[0].set_pressed(true)


func get_button_palette_index(button: PaletteRadioButton) -> int:
	return palettes.find(button.palette)


func get_palette_index_button(palette_index: int) -> PaletteRadioButton:
	for button: PaletteRadioButton in button_group.get_buttons():
		if button.palette == palettes[palette_index]:
			return button

	return null


func get_preferred_indexes() -> Array[int]:
	var preferred_indexes: Array[int]
	for button: PaletteRadioButton in button_container.get_children():
		preferred_indexes.append(get_button_palette_index(button))

	return preferred_indexes


func set_preferred_indexes(value: Array[int]) -> void:
	var validated: Array[int] = validate_preferred_indexes(value)
	for preferred_index in validated:
		button_container.reorder_child(
				get_palette_index_button(preferred_index).get_index(),
				validated.find(preferred_index)
		)


func move_pressed_button_by(value: int) -> void:
	var from: int = button_group.get_pressed_button().get_index()
	var to: int = posmod(from + value, button_container.get_children().size())
	button_container.reorder_child(from, to)


func set_pressed_palette_index(value: int) -> void:
	pressed_palette_index = posmod(value, palettes.size())
	get_palette_index_button(pressed_palette_index).set_pressed(true)
	pressed_palette_index_changed.emit(pressed_palette_index)


func validate_preferred_indexes(preferred_indexes: Array[int]) -> Array[int]:
	var validated: Array[int]
	for preferred_index in preferred_indexes:
		if preferred_index < 0:
			continue

		if preferred_index >= palettes.size():
			continue

		if preferred_index in validated:
			continue

		validated.append(preferred_index)

	for i in palettes.size():
		if i not in validated:
			validated.append(i)

	assert(validated.size() == palettes.size())
	for i in validated:
		assert(validated.count(i) == 1)

	return validated


func _on_button_group_pressed(button: BaseButton) -> void:
	pressed_palette_index = palettes.find(
			(button as PaletteRadioButton).palette
	)


func _on_left_pressed() -> void:
	move_pressed_button_by(-1)


func _on_right_pressed() -> void:
	move_pressed_button_by(1)


func _on_button_container_reordered(_from: int, _to: int) -> void:
	preferred_indexes_changed.emit()
