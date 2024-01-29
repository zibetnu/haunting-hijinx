extends Node


@export var sprite: Sprite2D
@export var clear_on_ready := false


var _texture: Texture2D


func _ready() -> void:
	if clear_on_ready:
		clear_texture()


func clear_texture() -> void:
	_texture = sprite.texture
	sprite.texture = null


func restore_texture() -> void:
	if sprite.texture != null:
		return

	sprite.texture = _texture
