extends OptionButton
## An Optionbutton with additional id-focused functionality.


signal item_id_focused(id: int)
signal item_id_selected(id: int)


func _init() -> void:
	item_focused.connect(
			func(idx: int) -> void: item_id_focused.emit(get_item_id(idx))
	)
	item_selected.connect(
			func(idx: int) -> void: item_id_selected.emit(get_item_id(idx))
	)


func select_id(id: int) -> void:
	select(get_item_index(id))
