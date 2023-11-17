extends Node2D


var _shape_points := []


func _draw() -> void:
	if _shape_points.size() >= 3:
		draw_colored_polygon(_shape_points, Color8(255, 255 , 255))


func update_shape(all_colliders_and_points: Array, raycasts: Array) -> void:
	var rotated_collision_points := []
	for i in range(mini(all_colliders_and_points.size(), raycasts.size())):
		rotated_collision_points.append(_get_rotated_collision_point(
				all_colliders_and_points[i], raycasts[i]
		))

	# Assume that raycast positions are vertically sorted, which means that
	# reversing the list of collision points will make the points be in the
	# final array be in the order needed to outline a polygon.
	rotated_collision_points.reverse()
	var new_shape_points = (
		raycasts.map(func(raycast): return raycast.position) + rotated_collision_points
	)

	if _shape_points != new_shape_points:
		_shape_points = new_shape_points
		queue_redraw()


func _get_rotated_collision_point(colliders_and_points: Dictionary, raycast: RayCast2D) -> Vector2:
	if (
			colliders_and_points.collision_points.size() == 0
			# Assume that collider and point arrays have been resized to stop
			# at the first node that's in the stop_flashlight group.
			or not colliders_and_points.colliders[-1].is_in_group("stop_flashlight")
	):
		return (raycast.position
				+ Vector2(raycast.target_position.length(), 0).rotated(raycast.rotation)
		)

	var collision_point := raycast.to_local(colliders_and_points.collision_points[-1])
	return raycast.position + Vector2(collision_point.length(), 0).rotated(raycast.rotation)
