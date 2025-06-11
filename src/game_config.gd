class_name GameConfig
extends RefCounted

static var file_path: String = get_config_dir().path_join("settings.cfg")

static var _config_file := ConfigFile.new()


static func _static_init() -> void:
	DirAccess.make_dir_absolute(get_config_dir())
	_config_file.load(file_path)


static func get_config_dir() -> String:
	var user_dir_name: String = ProjectSettings.get_setting(
			"application/config/custom_user_dir_name", ""
	)
	return OS.get_config_dir().path_join(user_dir_name)


static func get_value(
		section: String,
		key: String,
		default: Variant = null
) -> Variant:
	return _config_file.get_value(section, key, default)


static func save() -> void:
	_config_file.save(file_path)


static func set_value(
		section: String,
		key: String,
		value: Variant,
) -> void:
	_config_file.set_value(section, key, value)
