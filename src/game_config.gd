class_name GameConfig
extends RefCounted

const FILE_PATH = "user://settings.cfg"

static var _config_file := ConfigFile.new()


static func _static_init() -> void:
	_config_file.load(FILE_PATH)


static func get_value(
		section: String,
		key: String,
		default: Variant = null
) -> Variant:
	return _config_file.get_value(section, key, default)


static func save() -> void:
	_config_file.save(FILE_PATH)


static func set_value(
		section: String,
		key: String,
		value: Variant,
) -> void:
	_config_file.set_value(section, key, value)
