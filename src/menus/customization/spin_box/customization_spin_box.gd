@tool
class_name CustomizationSpinBox
extends Control

signal item_selected(index: int)

@export var option_name: String = "Option Name":
	set = set_option_name
@export var items: Array[String] = []
@export var selected: int:
	set = set_selected

@onready var option_name_label: Label = $VBoxContainer/OptionNameLabel
@onready var selected_item_label: Label = $VBoxContainer/SelectedItemLabel


func _ready() -> void:
	_apply_option_name()
	_apply_selected()


func set_option_name(value: String) -> void:
	option_name = value
	if is_node_ready():
		_apply_option_name()


func set_selected(value: int) -> void:
	selected = 0 if items.is_empty() else value % items.size()
	if is_node_ready():
		_apply_selected()


func _apply_option_name() -> void:
	option_name_label.text = option_name


func _apply_selected() -> void:
	selected_item_label.text = "" if items.is_empty() else items[selected]
	if not Engine.is_editor_hint():
		item_selected.emit(selected)


func _on_left_pressed() -> void:
	selected -= 1


func _on_right_pressed() -> void:
	selected += 1
