extends Node


signal loaded(value: Variant)
signal load_failed
signal saved
signal save_failed

const PATH_SETTING_NAME = "application/config/config_path"

@export var section: String
@export var key: String

@onready var _path := ProjectSettings.get_setting(PATH_SETTING_NAME) as String


func load_value() -> void:
	var config_file: ConfigFile = _get_existing_config_file()
	if not config_file.has_section_key(section, key):
		load_failed.emit()
		return

	loaded.emit(config_file.get_value(section, key))


func save_value(value: Variant) -> void:
	var config_file: ConfigFile = _get_existing_config_file()
	config_file.set_value(section, key, value)
	var error: Error = config_file.save(_path)
	if error != OK:
		save_failed.emit()
		return

	saved.emit()


func _get_existing_config_file() -> ConfigFile:
	var config_file := ConfigFile.new()
	config_file.load(_path)
	return config_file
