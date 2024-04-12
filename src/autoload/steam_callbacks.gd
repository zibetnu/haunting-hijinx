extends Node


func _ready() -> void:
	Steam.steamInit()
	set_process(Steam.isSteamRunning())


func _process(_delta: float) -> void:
	Steam.run_callbacks()
