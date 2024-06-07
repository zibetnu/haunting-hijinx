extends Control


@export var first_button: Button


func _ready() -> void:
	first_button.grab_focus()


func _on_browse_lobbies_pressed() -> void:
	SceneChanger.change_to_lobby_browser()


func _on_quit_pressed() -> void:
	get_tree().quit()
