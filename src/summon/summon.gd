class_name Summon
extends Node


signal summoned

const DrainArea := preload("res://src/summon/drain_area/drain_area.tscn")

@export var charge_time := 4.0
@export var charging := false:
	set(value):
		charging = value
		set_physics_process(value)

@export var target_group: StringName

var charge := 0:
	set(value):
		charge = clampi(value, 0, max_charge)
		if charge == max_charge:
			charge = 0
			spawn_scenes()
			summoned.emit()

var max_charge: int:
	get:
		return (charge_time
				* ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))


func _ready() -> void:
	set_physics_process(charging)


func spawn_scenes() -> void:
	for node in get_tree().get_nodes_in_group(target_group):
		var instance := DrainArea.instantiate()
		instance.position = node.position
		owner.add_sibling(instance, true)


func _physics_process(_delta: float) -> void:
	charge += 1
