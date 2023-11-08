extends Node2D


@export var aura: Aura


func _ready() -> void:
	visible = aura.player.peer_id == multiplayer.get_unique_id()


func _draw() -> void:
	draw_arc(aura.position, aura.radius, 0, 2 * PI, 32, Color8(255, 255, 255, 63))
