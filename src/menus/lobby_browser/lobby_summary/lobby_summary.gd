class_name LobbySummary
extends BaseButton

const GOOD_COLOR = Color.GREEN
const OKAY_COLOR = Color.ORANGE
const BAD_COLOR = Color.RED

const GOOD_PING_MAX = 99
const OKAY_PING_MAX = 199

var lobby_id := -1
var lobby_name := "Unknown":
	set(value):
		lobby_name = value
		lobby_name_label.text = value

var lobby_type := "Unknown":
	set(value):
		lobby_type = value
		lobby_type_label.text = value

var ping := 999:
	set(value):
		ping = value
		ping_label.text = "%s ms" % value
		_update_ping_label_color()

var player_count := 0:
	set(value):
		player_count = value
		player_count_label.text = "%s/%s" % [player_count, player_limit]

var player_limit := 0:
	set(value):
		player_limit = value
		player_count_label.text = "%s/%s" % [player_count, player_limit]

@onready var lobby_name_label: Label = %LobbyName
@onready var lobby_type_label: Label = %LobbyType
@onready var ping_label: Label = %Ping
@onready var player_count_label: Label = %PlayerCount


func _to_string() -> String:
	return "Lobby %s \n\tName: %s\n\tType: %s\n\tPlayers: %s\n\tPing: %s" % [
		lobby_id, lobby_name, lobby_type, player_count_label.text, ping
	]


func _update_ping_label_color() -> void:
	if ping <= GOOD_PING_MAX:
		ping_label.modulate = GOOD_COLOR

	elif ping <= OKAY_PING_MAX:
		ping_label.modulate = OKAY_COLOR

	else:
		ping_label.modulate = BAD_COLOR
