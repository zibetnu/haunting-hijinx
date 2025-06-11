class_name ConfigHandler
extends Node

signal loaded(value: Variant)
signal load_failed
signal saved
signal save_failed
signal staged_value_changed(staged_value: Variant)

static var path: String = GameConfig.get_config_dir().path_join("settings.cfg")

static var _config_file: ConfigFile:
	get = _get_config_file

@export var section: String
@export var key: String

## The default value passed to [method save_value].
var staged_value: Variant:
	set = set_staged_value


func load_value() -> void:
	if not _config_file.has_section_key(section, key):
		load_failed.emit()
		return

	loaded.emit(_config_file.get_value(section, key))


func save_value(value: Variant = staged_value) -> void:
	_config_file.set_value(section, key, value)
	var error: Error = _config_file.save(path)
	if error != OK:
		save_failed.emit()
		return

	saved.emit()


func set_staged_value(value: Variant) -> void:
	if value == staged_value:
		return

	staged_value = value
	staged_value_changed.emit(staged_value)


static func _get_config_file() -> ConfigFile:
	if _config_file == null:
		_config_file = ConfigFile.new()
		_config_file.load(path)

	return _config_file
