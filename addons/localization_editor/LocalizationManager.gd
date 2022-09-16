# LocalizationManager for usege with placeholders: MIT License
# @author Vladimir Petrenko
extends Node

signal translation_changed

const _pseudolocalization_control: String = "internationalization/pseudolocalization/use_pseudolocalization_control"
const _pseudolocalization_ui = preload("res://addons/localization_editor/scenes/pseudolocalization/ui/LocalizationPseudolocalizationForUI.tscn")

var _path_to_save = "user://localization.tres"
var _keys_with_placeholder: Dictionary = {}
var _placeholders_default: Dictionary = {}
var _placeholders: Dictionary = {}
var _data_remaps: Dictionary = {}

func _ready() -> void:
	_load_pseudolocalization_control()
	_load_localization()
	_load_placeholders_default()
	_load_localization_keys()
	_load_data_remaps()

func _load_pseudolocalization_control() -> void:
	if ProjectSettings.has_setting(_pseudolocalization_control) and ProjectSettings.get_setting(_pseudolocalization_control) == true:
		var root_node = get_tree().get_root()
		root_node.call_deferred("add_child", _pseudolocalization_ui.instantiate())

func _load_placeholders_default() -> void:
	var file = File.new()
	if file.file_exists(LocalizationData.default_path_to_placeholders):
		var resource = ResourceLoader.load(LocalizationData.default_path_to_placeholders)
		if resource and resource.placeholders and not resource.placeholders.size() <= 0:
			_placeholders_default = resource.placeholders

func _load_localization_keys() -> void:
	var regex = RegEx.new()
	regex.compile("{{(.+?)}}")
	for _localization_key in LocalizationKeys.KEYS:
		var results = regex.search_all(tr(_localization_key))
		for result in results:
			var name = result.get_string()
			var clean_name = name.replace("{{", "");
			clean_name = clean_name.replace("}}", "");
			_add_placeholder(_localization_key, clean_name)

func _add_placeholder(key: String, placeholder_key: String) -> void:
	if not _keys_with_placeholder.has(key):
		_keys_with_placeholder[key] = []
	var placeholder_keys = _keys_with_placeholder[key] as Array
	if not placeholder_keys.has(placeholder_key):
		placeholder_keys.append(placeholder_key)

func set_placeholder(name: String, value: String, locale: String = "", profile: String = "DEFAULT") -> void:
	var loc = locale
	if loc.length() <= 0:
		loc = TranslationServer.get_locale()
	if not _placeholders.has(profile):
		_placeholders[profile] = {}
	if not _placeholders[profile].has(name):
		_placeholders[profile][name] = {}
	_placeholders[profile][name][loc] = value
	emit_signal("translation_changed")

func _load_data_remaps() -> void:
	var internationalization_path = "internationalization/locale/translation_remaps"
	_data_remaps.remapkeys = []
	if ProjectSettings.has_setting(internationalization_path):
		var settings_remaps = ProjectSettings.get_setting(internationalization_path)
		if settings_remaps.size():
			var keys = settings_remaps.keys();
			for key in keys:
				var remaps = []
				for remap in settings_remaps[key]:
					var index = remap.rfind(":")
					var locale  = remap.substr(index + 1)
					var value = remap.substr(0, index)
					var remap_new = {"locale": locale, "value": value }
					remaps.append(remap_new)
				var filename = key.get_file()
				_data_remaps[filename.replace(".", "_").to_upper()] = remaps

func tr_remap(key: String) -> String:
	for remap in _data_remaps[key]: 
		if remap["locale"] == TranslationServer.get_locale():
			return remap["value"]
	return ""

func tr(name: StringName, context: StringName = StringName("")) -> String:
	var tr_text = super.tr(name, context)
	if _keys_with_placeholder.has(name):
		for placeholder in _keys_with_placeholder[name]:
			tr_text = tr_text.replace("{{" + placeholder + "}}", _placeholder_by_key(placeholder))
	return tr_text

func  _placeholder_by_key(key: String, profile: String = "DEFAULT") -> String:
	var value = ""
	if value.length() <= 0 and _placeholders.has(profile) and _placeholders[profile].has(key) and _placeholders[profile][key].has(TranslationServer.get_locale()):
		value = _placeholders[profile][key][TranslationServer.get_locale()]
	if value.length() <= 0 and _placeholders_default.has(key) and _placeholders_default[key].has(TranslationServer.get_locale()):
		value = _placeholders_default[key][TranslationServer.get_locale()]
	return value

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_TRANSLATION_CHANGED:
			_save_localization()
			emit_signal("translation_changed")

func _load_localization():
	var file = File.new()
	if file.file_exists(_path_to_save):
		var loaded_data = load(_path_to_save) as LocalizationSave
		if loaded_data:
			if loaded_data.placeholders and not loaded_data.placeholders.is_empty():
				for key in loaded_data.placeholders.keys():
					_placeholders[key] = loaded_data.placeholders[key]
			if loaded_data.locale and not loaded_data.locale.is_empty():
				TranslationServer.set_locale(loaded_data.locale)

func _save_localization() -> void:
	var save_data = LocalizationSave.new()
	save_data.locale = TranslationServer.get_locale()
	save_data.placeholders = _placeholders
	assert(ResourceSaver.save(save_data, _path_to_save) == OK)
