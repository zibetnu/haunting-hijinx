extends MarginContainer

const CANCEL_ACTION = &"ui_cancel"

@export var ghost: Button
@export var hunter: Button
@export var back: Button

@onready var ghost_costume: GhostCostume = %GhostCostume
@onready var hunter_costume: HunterCostume = %HunterCostume


func _ready() -> void:
	# https://github.com/godotengine/godot/issues/77643
	@warning_ignore("unsafe_call_argument")
	@warning_ignore("unsafe_method_access")
	@warning_ignore("unsafe_property_access")
	ghost.pressed.connect(SceneChanger.change_to_ghost_tutorial)

	ghost_costume.play("idle")

	@warning_ignore("unsafe_call_argument")
	@warning_ignore("unsafe_method_access")
	@warning_ignore("unsafe_property_access")
	hunter.pressed.connect(SceneChanger.change_to_hunter_tutorial)

	hunter_costume.play("move")


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(CANCEL_ACTION):
		back.pressed.emit()
		accept_event()
