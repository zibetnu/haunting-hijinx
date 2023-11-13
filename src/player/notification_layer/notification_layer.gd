extends CanvasLayer


@export var player: Player


func _physics_process(_delta: float) -> void:
	offset = player.position
	visible = player.visible
