class_name RepeatRayCast2D
extends Node2D

@export var enabled := true:
	set(value):
		enabled = value
		set_physics_process(enabled)

@export var exclude_parent := true  # TODO: figure out implementation.
@export var target_position := Vector2(0, 50):
	set(value):
		if not is_node_ready():
			await ready

		target_position = value
		_ray_cast_2d.target_position = target_position
		_repeat_ray_cast_2d.target_position = target_position

## The non-repeating ray's collision mask. Only objects in at least one
## collision layer enabled in the mask will be detected.
@export_flags_2d_physics var collision_mask := 1:
	set(value):
		if not is_node_ready():
			await ready

		collision_mask = value
		_ray_cast_2d.collision_mask = collision_mask
		_repeat_ray_cast_2d.collision_mask = (
				collision_mask | repeat_collision_mask
		)

## The repeating ray's collision mask. Only objects in at least one collision
## layer enabled in the mask will be detected.
@export_flags_2d_physics var repeat_collision_mask := 1:
	set(value):
		if not is_node_ready():
			await ready

		repeat_collision_mask = value
		_repeat_ray_cast_2d.collision_mask = (
				collision_mask | repeat_collision_mask
		)

@export var hit_from_inside := false:
	set(value):
		if not is_node_ready():
			await ready

		hit_from_inside = value
		_ray_cast_2d.hit_from_inside = hit_from_inside
		_repeat_ray_cast_2d.hit_from_inside = hit_from_inside

@export_group("Collide With", "collide_with")
@export var collide_with_areas := false:
	set(value):
		if not is_node_ready():
			await ready

		collide_with_areas = value
		_ray_cast_2d.collide_with_areas = collide_with_areas
		_repeat_ray_cast_2d.collide_with_areas = collide_with_areas

@export var collide_with_bodies := true:
	set(value):
		if not is_node_ready():
			await ready

		collide_with_bodies = value
		_ray_cast_2d.collide_with_bodies = collide_with_bodies
		_repeat_ray_cast_2d.collide_with_bodies = collide_with_bodies

var _colliders: Array[Object] = []
var _collision_points: Array[Vector2] = []

@onready var _ray_cast_2d: RayCast2D = $RayCast2D
@onready var _repeat_ray_cast_2d: RayCast2D = $RepeatRayCast2D


func _physics_process(_delta: float) -> void:
	if not enabled:
		return

	_colliders = []
	_collision_points = []

	var stop_at_rid := _ray_cast_2d.get_collider_rid()
	while _repeat_ray_cast_2d.is_colliding():
		_colliders.append(_repeat_ray_cast_2d.get_collider())
		_collision_points.append(_repeat_ray_cast_2d.get_collision_point())
		var collider_rid := _repeat_ray_cast_2d.get_collider_rid()
		if collider_rid == stop_at_rid:
			break

		_repeat_ray_cast_2d.add_exception_rid(collider_rid)
		_repeat_ray_cast_2d.force_raycast_update()

	_repeat_ray_cast_2d.clear_exceptions()


## Returns all of the objects that the repeating ray intersects, up to and
## including the first object that the non-repeating ray insersects.
func get_colliders() -> Array[Object]:
	return _colliders


func get_collision_point() -> Vector2:
	return _ray_cast_2d.get_collision_point()


## Returns all of the collision points at which the repeating ray intersects
## objects, up to and including the collision point at which the non-repeating
## ray intersects the closest object.
## [br][br]
## [b]Note:[/b] These points are in the [b]global[/b] coordinate system.
func get_collision_points() -> Array[Vector2]:
	return _collision_points


func is_colliding() -> bool:
	return _ray_cast_2d.is_colliding()
