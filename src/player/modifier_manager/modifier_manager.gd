class_name ModifierManager
extends Node


@export var player: Player

var _modifiers: Array[Modifier] = []


func add_modifier(modifier: Modifier) -> void:
	if modifier in _modifiers:
		return

	_modifiers.append(modifier)
	modifier.modify(player)


func remove_all_modifiers() -> void:
	_unmodify_all()
	_modifiers.clear()


func remove_modifier(modifier: Modifier) -> void:
	if not modifier in _modifiers:
		return

	_unmodify_all()
	_modifiers.erase(modifier)
	_modify_all()


func _modify_all() -> void:
	for modifier in _modifiers:
		modifier.modify(player)


func _unmodify_all() -> void:
	for i in range(_modifiers.size(), 0, -1):
		_modifiers[i - 1].unmodify()
