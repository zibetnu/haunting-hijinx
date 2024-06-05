class_name Summon
extends Node


signal area_count_changed(area_count: int)
signal charge_percentage_changed(value: float)
signal summon_charged
signal summon_charging
signal summoned

const DrainArea := preload("res://src/summon/drain_area/drain_area.tscn")

@export var charge_time := 4.0
@export var charging := false:
	set(value):
		charging = value
		set_physics_process(charging)
		if charging:
			summon_charging.emit()

@export var target_group: StringName

var area_count := 0:
	set(value):
		area_count = value
		area_count_changed.emit(area_count)

var charge := 0:
	set(value):
		charge = clampi(value, 0, max_charge)
		charge_percentage_changed.emit(charge / float(max_charge))
		if charge == max_charge:
			summon_charged.emit()

var max_charge: int:
	get:
		return (charge_time
				* ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))


func _ready() -> void:
	set_physics_process(charging)


func clear_charge() -> void:
	charge = 0


func set_charging(value: bool) -> void:
	charging = value


func spawn_scenes() -> void:
	for node in get_tree().get_nodes_in_group(target_group):
		var instance := DrainArea.instantiate()
		instance.position = node.position
		instance.tree_entered.connect(func(): area_count += 1)
		instance.tree_exited.connect(func(): area_count -= 1)
		owner.add_sibling(instance, true)

	summoned.emit()


func release_charge() -> void:
	if charge == max_charge:
		spawn_scenes()

	charge = 0


func start_charging() -> void:
	charging = true


func stop_charging() -> void:
	charging = false


func _physics_process(_delta: float) -> void:
	charge += 1
