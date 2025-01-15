extends Tutorial

@export var battery_quest: Quest

@onready var npc_hunter: CharacterBody2D = $NPCHunter


func _ready() -> void:
	super()
	make_npc(ghost)
	make_npc(npc_hunter)


func _on_battery_spawned(battery: Battery) -> void:
	battery.acquired.connect(battery_quest.complete)
