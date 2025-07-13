class_name Summon
extends Node

signal area_count_changed(area_count: int)
signal charged
signal started
signal stopped
signal summoned

@export var drain_area: PackedScene
@export var charge_time := 4.0
@export var target_group: StringName

var area_count := 0:
	set(value):
		area_count = value
		area_count_changed.emit(area_count)

var charge := 0:
	set(value):
		charge = clampi(value, 0, max_charge)
		if charge == max_charge:
			charged.emit()

var max_charge: int:
	get:
		return (
				charge_time
				* ProjectSettings.get_setting(
						"physics/common/physics_ticks_per_second"
				)
		)


func _ready() -> void:
	set_physics_process(false)


func spawn_scenes() -> void:
	for node: Node2D in get_tree().get_nodes_in_group(target_group):
		var instance: Node2D = drain_area.instantiate()
		instance.position = node.position
		instance.tree_entered.connect(func() -> void: area_count += 1)
		instance.tree_exited.connect(func() -> void: area_count -= 1)
		owner.add_sibling(instance, true)

	summoned.emit()


func release_charge() -> void:
	if charge == max_charge:
		spawn_scenes()

	stop_charging()


func start_charging() -> void:
	charge = 0
	set_physics_process(true)
	started.emit()


func stop_charging() -> void:
	set_physics_process(false)
	charge = 0
	stopped.emit()


func _physics_process(_delta: float) -> void:
	charge += 1
