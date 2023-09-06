class_name RepeatRayCast2D
extends RayCast2D


func get_colliders() -> Array[Object]:
	var colliders: Array[Object] = []
	var exception_rids: Array[RID] = []
	while is_colliding():
		colliders.append(get_collider())
		var collider_rid := get_collider_rid()
		exception_rids.append(collider_rid)
		add_exception_rid(collider_rid)
		force_raycast_update()

	exception_rids.map(remove_exception_rid)
	return colliders
