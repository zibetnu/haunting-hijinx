extends State


@export var exit_state: State
@export var max_charge := 240
@export var summon_scene: PackedScene

var charge := 0:
	set(new_charge):
		charge = clampi(new_charge, 0, max_charge)


func physics_update(_delta: float) -> void:
	charge += 1
	if charge < max_charge:
		return

	if not multiplayer.is_server():
		return

	for hunter in get_tree().get_nodes_in_group("hunters"):
		var instance := summon_scene.instantiate()
		instance.global_position = hunter.global_position
		owner.get_parent().add_child(instance, true)

	state_machine.transition_to.rpc(exit_state.name)


func exit() -> void:
	charge = 0
