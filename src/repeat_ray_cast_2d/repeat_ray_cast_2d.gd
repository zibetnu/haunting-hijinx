class_name RepeatRayCast2D
extends RayCast2D


## The repeating ray's collision mask. Only objects in at least one collision
## layer enabled in the mask will be detected.
@export_flags_2d_physics var repeat_collision_mask := 1

var _colliders: Array[Object] = []
var _collision_points: Array[Vector2] = []


func _physics_process(_delta: float) -> void:
	if not enabled:
		return

	_colliders = []
	_collision_points = []

	var query := PhysicsRayQueryParameters2D.create(
			global_position,
			to_global(position + target_position),
			# Include collision_mask so the loop will know to stop at stop_at.
			repeat_collision_mask | collision_mask
	)
	query.collide_with_areas = collide_with_areas
	query.collide_with_bodies = collide_with_bodies
	query.hit_from_inside = hit_from_inside
	var exclude: Array[RID] = []  # TODO: take exclude_parent into account.
	var space_state := get_world_2d().direct_space_state
	var result := space_state.intersect_ray(query)
	var stop_at := get_collider_rid()
	while not result.is_empty() and result.rid != stop_at:
		_colliders.append(result.collider)
		_collision_points.append(result.position)
		exclude.append(result.rid)
		query.exclude = exclude
		result = space_state.intersect_ray(query)

	if is_colliding():
		_colliders.append(get_collider())
		_collision_points.append(get_collision_point())


## Returns all of the objects that the repeating ray intersects, up to and
## including the first object that the non-repeating ray insersects.
func get_colliders() -> Array[Object]:
	return _colliders


## Returns all of the collision points at which the repeating ray intersects
## objects, up to and including the collision point at which the non-repeating
## ray intersects the closest object.
## [br][br]
## [b]Note:[/b] These points are in the [b]global[/b] coordinate system.
func get_collision_points() -> Array[Vector2]:
	return _collision_points
