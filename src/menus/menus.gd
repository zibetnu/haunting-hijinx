extends TabContainer

@onready var steam_connector: SteamConnector = $SteamConnector


func _ready() -> void:
	steam_connector.close_connection()
