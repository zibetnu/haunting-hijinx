class_name Menus
extends TabContainer

enum Tab {
	MAIN = 0,
	CONFIG = 1,
	ABOUT = 2,
	LICENSE = 3,
	TUTORIAL = 4,
	CUSTOMIZATION = 5,
	LOBBY_BROWSER = 6,
}

@onready var steam_connector: SteamConnector = $SteamConnector


func _ready() -> void:
	steam_connector.close_connection()


func _on_customization_back_pressed() -> void:
	current_tab = Tab.MAIN


func _on_customization_pressed() -> void:
	current_tab = Tab.CUSTOMIZATION


func _on_browse_lobbies_pressed() -> void:
	current_tab = Tab.LOBBY_BROWSER


func _on_lobby_browser_back_pressed() -> void:
	current_tab = Tab.MAIN
