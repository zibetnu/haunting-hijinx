extends Control


func _on_browse_lobbies_pressed() -> void:
	SceneChanger.change_to_lobby_browser()


func _on_quit_pressed() -> void:
	get_tree().quit()
