class_name CustomizationMenu
extends Control

signal back_pressed
signal pressed_sound_requested

@export var first_button: BaseButton

@onready var ghost_hat_spin_box: CustomizationSpinBox = %GhostHatSpinBox
@onready var hunter_hat_spin_box: CustomizationSpinBox = %HunterHatSpinBox
@onready var hunter_palette_preferences: PalettePreferences = %HunterPalettePreferences
@onready var default_name: LineEdit = %DefaultName
@onready var ghost_costume: GhostCostume = %GhostCostume
@onready var hunter_costume: HunterCostume = %HunterCostume
@onready var flashlight_back: Sprite2D = %FlashlightBack
@onready var flashlight_front: Sprite2D = %FlashlightFront


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	default_name.text = GameConfig.default_name.get_value()
	init_ghost()
	init_hunter()


func init_ghost() -> void:
	ghost_hat_spin_box.items.clear()
	for hat in ghost_costume.hat_array:
		ghost_hat_spin_box.items.append(hat.resource_name)

	ghost_hat_spin_box.selected = GameConfig.ghost_hat.get_value()
	ghost_costume.play("idle")


func init_hunter() -> void:
	hunter_hat_spin_box.items.clear()
	for hat in hunter_costume.hat_array:
		hunter_hat_spin_box.items.append(hat.resource_name)

	hunter_hat_spin_box.selected = GameConfig.ghost_hat.get_value()

	var preferred_indexes: Array[int]
	preferred_indexes.assign(GameConfig.hunter_colors.get_value() as Array)

	hunter_palette_preferences.set_preferred_indexes(preferred_indexes)
	hunter_palette_preferences.preferred_indexes_changed.connect(
			_on_hunter_preferred_indexes_changed
	)

	set_block_signals(true)
	hunter_palette_preferences.pressed_palette_index_changed.connect(set_hunter_palette_index)
	if not preferred_indexes.is_empty():
		hunter_palette_preferences.pressed_palette_index = preferred_indexes[0]

	set_block_signals(false)
	hunter_costume.play("idle_no_flashlight")


func set_hunter_palette_index(index: int) -> void:
	hunter_costume.palette_index = index
	pressed_sound_requested.emit()


func _on_back_pressed() -> void:
	back_pressed.emit()


func _on_default_name_text_changed(new_text: String) -> void:
	GameConfig.default_name.set_value(new_text)


func _on_ghost_hat_spin_box_item_selected(index: int) -> void:
	if not is_node_ready():
		return

	ghost_costume.hat_index = index
	GameConfig.ghost_hat.set_value(ghost_costume.hat_index)


func _on_hunter_hat_spin_box_item_selected(index: int) -> void:
	if not is_node_ready():
		return

	hunter_costume.hat_index = index
	GameConfig.hunter_hat.set_value(hunter_costume.hat_index)


func _on_tab_container_tab_changed(tab: int) -> void:
	ghost_costume.visible = tab == 0
	hunter_costume.visible = tab == 1


func _on_visibility_changed() -> void:
	if visible:
		first_button.grab_focus()


func _on_hunter_preferred_indexes_changed() -> void:
	GameConfig.hunter_colors.set_value(hunter_palette_preferences.get_preferred_indexes())
