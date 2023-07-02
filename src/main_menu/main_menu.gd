extends Control


func _ready() -> void:
	%HostButton.grab_focus()


func start_lobby() -> void:
	SceneChanger.change_scene_to_packed(SceneChanger.lobby)


func _on_host_button_pressed() -> void:
	ConnectionManager.create_server(int(%PortText.text))
	start_lobby()


func _on_join_button_pressed() -> void:
	ConnectionManager.create_client(%IPText.text, int(%PortText.text))
	start_lobby()
