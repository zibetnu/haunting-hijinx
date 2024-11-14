extends Node

const APP_ID_PATH = "application/config/steam_app_id"


func _ready() -> void:
	Steam.steamInit(true, ProjectSettings.get_setting(APP_ID_PATH, 0))
	set_process(Steam.isSteamRunning())


func _process(_delta: float) -> void:
	Steam.run_callbacks()
