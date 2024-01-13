class_name CostumeBehavior
extends Node


const DIRECTION_NAMES = {
	Vector2.LEFT: "left",
	Vector2.RIGHT: "right",
	Vector2.UP: "up",
	Vector2.DOWN: "down",
}

var animation_name := "idle":
	set(value):
		var old_animation_name = animation_name
		animation_name = value
		if not _update_animation():
			animation_name = old_animation_name

var direction_vector := Vector2.DOWN:
	set(value):
		if value.is_zero_approx():
			return

		direction_vector = value
		_update_animation()

@export var animation_player: AnimationPlayer


func _get_direction_name(direction: Vector2) -> String:
	var distance := 2 * PI
	var snapped_vector := Vector2.DOWN
	for vector in DIRECTION_NAMES:
		if abs(direction.angle_to(vector)) < distance:
			distance = abs(direction.angle_to(vector))
			snapped_vector = vector

	return DIRECTION_NAMES[snapped_vector]


func _update_animation() -> bool:
	var directional_animation_name := "%s_%s" % [
			animation_name, _get_direction_name(direction_vector)
	]

	for library_name in animation_player.get_animation_library_list():
		var library: AnimationLibrary = animation_player.get_animation_library(library_name)
		var lib_directional_animation_name := "%s/%s" % [library_name, directional_animation_name]
		if lib_directional_animation_name == animation_player.current_animation:
			return true

		if library.has_animation(directional_animation_name):
			animation_player.play(lib_directional_animation_name)
			return true

		if library.has_animation(animation_name):
			animation_player.play("%s/%s" % [library_name, animation_name])
			return true

	return false
