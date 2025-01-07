extends MarginContainer

@export var ghost_button: Button
@export var hunter_button: Button


func _ready() -> void:
	ghost_button.pressed.connect(SceneChanger.change_to_tutorial)
	hunter_button.pressed.connect(SceneChanger.change_to_hunter_tutorial)
