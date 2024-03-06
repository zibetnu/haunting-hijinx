extends Control


const SECTION = "network"
const IP_KEY = "ip_address"
const PORT_KEY = "port"

@onready var connecting_dialog: AcceptDialog = $ConnectingDialog
@onready var connection_failed_dialog: AcceptDialog = $ConnectionFailedDialog


func _ready() -> void:
	ConnectionManager.server_created.connect(start_lobby)
	multiplayer.connected_to_server.connect(queue_free)
	multiplayer.connection_failed.connect(func(): connection_failed_dialog.popup_centered())
	_load_address()
	%JoinButton.grab_focus()


func cancel_connection_attempt() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func start_lobby() -> void:
	_save_address()
	SceneChanger.change_scene_to_packed(SceneChanger.lobby)


func _load_address() -> void:
	var config := ConfigFile.new()
	if config.load(ProjectSettings.get_setting("global/settings_file_path")) != OK:
		return

	if not config.has_section(SECTION):
		return

	if config.has_section_key(SECTION, IP_KEY):
		%IPText.text = config.get_value(SECTION, IP_KEY)

	if config.has_section_key(SECTION, PORT_KEY):
		var port: int = config.get_value(SECTION, PORT_KEY)
		if port != 0:
			%PortText.text = str(port)


func _save_address() -> void:
	var config := ConfigFile.new()
	config.set_value(SECTION, IP_KEY, %IPText.text)
	config.set_value(SECTION, PORT_KEY, int(%PortText.text))
	config.save(ProjectSettings.get_setting("global/settings_file_path"))


func _on_host_button_pressed() -> void:
	ConnectionManager.create_server(int(%PortText.text))


func _on_join_button_pressed() -> void:
	if not ConnectionManager.create_client(%IPText.text, int(%PortText.text)):
		return

	connecting_dialog.popup_centered()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
