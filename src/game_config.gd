class_name GameConfig
extends RefCounted

static var config_file := ConfigFile.new()
static var customization := ConfigSection.new("customization")
static var default_name: ConfigKey = customization.get_config_key("default_name", "")
static var ghost_body: ConfigKey = customization.get_config_key("ghost_body", 0)
static var ghost_hat: ConfigKey = customization.get_config_key("ghost_hat", 0)
static var hunter_body: ConfigKey = customization.get_config_key("hunter_body", 0)
static var hunter_hat: ConfigKey = customization.get_config_key("hunter_hat", 0)
static var hunter_colors: ConfigKey = customization.get_config_key("hunter_colors", [])

static var _file_path: String = _get_config_dir().path_join("settings.cfg")


static func _static_init() -> void:
	DirAccess.make_dir_absolute(_get_config_dir())
	config_file.load(_file_path)


static func get_value(section: String, key: String, default: Variant = null) -> Variant:
	config_file.load(_file_path)
	return config_file.get_value(section, key, default)


static func set_value(section: String, key: String, value: Variant) -> void:
	config_file.set_value(section, key, value)
	config_file.save(_file_path)


static func _get_config_dir() -> String:
	var user_dir_name: String = ProjectSettings.get_setting(
			"application/config/custom_user_dir_name", ""
	)
	return OS.get_config_dir().path_join(user_dir_name)


class ConfigSection extends RefCounted:
	var _section: String

	func _init(section: String) -> void:
		_section = section

	func get_as_dict() -> Dictionary[String, Variant]:
		var dict: Dictionary[String, Variant]
		for key in GameConfig.config_file.get_section_keys(_section):
			dict[key] = get_value(key)

		return dict

	func get_config_key(key: String, default: Variant = null) -> ConfigKey:
		return ConfigKey.new(_section, key, default)

	func get_value(key: String, default: Variant = null) -> Variant:
		return GameConfig.get_value(_section, key, default)

	func set_value(key: String, value: Variant) -> void:
		GameConfig.set_value(_section, key, value)


class ConfigKey extends RefCounted:
	var _section: String
	var _key: String
	var _default: Variant = null

	func _init(section: String, key: String, default: Variant = null) -> void:
		_section = section
		_key = key
		_default = default

	func get_value(default: Variant = _default) -> Variant:
		return GameConfig.get_value(_section, _key, default)

	func set_value(value: Variant) -> void:
		GameConfig.set_value(_section, _key, value)
