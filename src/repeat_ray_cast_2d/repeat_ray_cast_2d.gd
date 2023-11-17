class_name RepeatRayCast2D
extends RayCast2D


func get_colliders_and_points() -> Dictionary:
	var colliders: Array[Object] = []
	var collision_points: Array[Vector2] = []
	var exception_rids: Array[RID] = []
	while is_colliding():
		colliders.append(get_collider())
		collision_points.append(get_collision_point())
		var collider_rid := get_collider_rid()
		exception_rids.append(collider_rid)
		add_exception_rid(collider_rid)
		force_raycast_update()

	exception_rids.map(remove_exception_rid)
	return {"colliders": colliders, "collision_points": collision_points}
