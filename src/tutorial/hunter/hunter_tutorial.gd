extends Tutorial

@export var battery_quest: Quest

@onready var battery_spawner: BatterySpawner = $BatterySpawner
@onready var npc_hunter: CharacterBody2D = $NPCHunter


func _ready() -> void:
	super()
	battery_spawner.limit_bottom_right = level.limit_bottom_right
	battery_spawner.limit_top_left = level.limit_top_left
	make_npc(ghost)
	make_npc(npc_hunter)


func _on_battery_spawned(battery: Battery) -> void:
	battery.acquired.connect(battery_quest.complete)
