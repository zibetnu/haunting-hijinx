class_name Costume
extends Node2D


const DIRECTION_NAMES = {
	Vector2.LEFT: "left",
	Vector2.RIGHT: "right",
	Vector2.UP: "up",
	Vector2.DOWN: "down",
}

var animation_name := "idle":
	set(value):
		animation_name = value
		_update_animation()

var direction_vector := Vector2.DOWN:
	set(value):
		direction_vector = value
		_update_animation()


func _get_direction_name(direction: Vector2) -> String:
	var distance := 2 * PI
	var snapped_vector := Vector2.DOWN
	for vector in DIRECTION_NAMES:
		if abs(direction.angle_to(vector)) < distance:
			distance = abs(direction.angle_to(vector))
			snapped_vector = vector

	return DIRECTION_NAMES[snapped_vector]


func _update_animation() -> void:
	var directional_animation_name := "%s_%s" % [
			animation_name, _get_direction_name(direction_vector)
	]

	if directional_animation_name == $AnimationPlayer.current_animation:
		return

	if $AnimationPlayer.has_animation(directional_animation_name):
		$AnimationPlayer.play(directional_animation_name)
		return

	if $AnimationPlayer.has_animation(animation_name):
		$AnimationPlayer.play(animation_name)
		return


