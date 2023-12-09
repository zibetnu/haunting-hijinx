extends State


@export var charge_time := 4
@export var exit_state: State
@export var summon_scene: PackedScene

var charge := 0:
	set(new_charge):
		charge = clampi(new_charge, 0, max_charge)

var max_charge: int:
	get:
		return (charge_time
				* ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))


func physics_update(_delta: float) -> void:
	charge += 1


func spawn_scenes() -> void:
	for hunter in get_tree().get_nodes_in_group("hunters"):
		var instance := summon_scene.instantiate()
		instance.position = hunter.position
		owner.get_parent().add_child(instance, true)


func exit() -> void:
	if charge == max_charge and multiplayer.is_server():
		spawn_scenes()

	charge = 0
