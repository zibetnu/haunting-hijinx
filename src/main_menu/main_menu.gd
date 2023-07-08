extends Control


const SECTION = "network"
const IP_KEY = "ip_address"
const PORT_KEY = "port"


func _ready() -> void:
	_load_address()
	%HostButton.grab_focus()


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


func _on_host_button_pressed() -> void:
	ConnectionManager.create_server(int(%PortText.text))
	start_lobby()


func _on_join_button_pressed() -> void:
	ConnectionManager.create_client(%IPText.text, int(%PortText.text))
	start_lobby()


func _save_address() -> void:
	var config := ConfigFile.new()
	config.set_value(SECTION, IP_KEY, %IPText.text)
	config.set_value(SECTION, PORT_KEY, int(%PortText.text))
	config.save(ProjectSettings.get_setting("global/settings_file_path"))
