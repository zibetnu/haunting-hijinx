extends TabContainer

@onready var steam_connector: SteamConnector = $SteamConnector


func _ready() -> void:
	steam_connector.close_connection()


func _on_customization_back_pressed() -> void:
	current_tab = 0


func _on_customization_pressed() -> void:
	current_tab = 5
