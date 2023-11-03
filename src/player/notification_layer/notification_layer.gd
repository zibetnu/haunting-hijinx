extends CanvasLayer


@export var player: Player


func _process(_delta: float) -> void:
	offset = player.position
	visible = player.visible
