# LocalizationEditor : MIT License
# @author Vladimir Petrenko
@tool
extends Control

var _editor: EditorPlugin
var _data:= LocalizationData.new()

@onready var _save_ui = $VBox/Margin/HBox/Save
@onready var _open_ui = $VBox/Margin/HBox/Open
@onready var _file_ui = $VBox/Margin/HBox/File
@onready var _tabs_ui = $VBox/Tabs as TabContainer
@onready var _locales_ui = $VBox/Tabs/Locales
@onready var _remaps_ui = $VBox/Tabs/Remaps
@onready var _placeholders_ui = $VBox/Tabs/Placeholders
@onready var _translations_ui = $VBox/Tabs/Translations
@onready var _auto_translate_ui = $VBox/Tabs/AutoTranslate

const IconResourceTranslations = preload("res://addons/localization_editor/icons/Localization.svg")
const IconResourceRemaps = preload("res://addons/localization_editor/icons/Remaps.svg")
const IconResourceLocales = preload("res://addons/localization_editor/icons/Locales.svg")
const IconResourcePlaceholders = preload("res://addons/localization_editor/icons/Placeholders.svg")
const IconResourcePseudolocalization = preload("res://addons/localization_editor/icons/Pseudolocalization.svg")
const IconResourceTranslation = preload("res://addons/localization_editor/icons/Translation.svg")

const LocalizationEditorDialogFile = preload("res://addons/localization_editor/LocalizationEditorDialogFile.tscn")

func _ready() -> void:
	_tabs_ui.set_tab_icon(0, IconResourceTranslations)
	_tabs_ui.set_tab_icon(1, IconResourceRemaps)
	_tabs_ui.set_tab_icon(2, IconResourceLocales)
	_tabs_ui.set_tab_icon(3, IconResourcePlaceholders)
	_tabs_ui.set_tab_icon(4, IconResourcePseudolocalization)
	_tabs_ui.set_tab_icon(5, IconResourceTranslation)
	_tabs_ui.connect("tab_changed", _on_tab_changed)

func _on_tab_changed(idx: int) -> void:
	if idx == 3:
		_data.init_data_placeholders()
		_data.emit_signal_data_changed()

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_init_connections()
	_load_data()
	_data.set_editor(editor)
	_data_to_childs()
	_update_view()

func _init_connections() -> void:
	if not _data.is_connected("settings_changed", _update_view):
		assert(_data.connect("settings_changed", _update_view) == OK)
	if not _save_ui.is_connected("pressed", _on_save_data):
		assert(_save_ui.connect("pressed", _on_save_data) == OK)
	if not _open_ui.is_connected("pressed", _open_file):
		assert(_open_ui.connect("pressed", _open_file) == OK)

func get_data() -> LocalizationData:
	return _data

func _load_data() -> void:
	_data.init_data_translations()
	_data.init_data_remaps()
	_data.init_data_placeholders()

func _data_to_childs() -> void:
	_translations_ui.set_data(_data)
	_remaps_ui.set_data(_data)
	_locales_ui.set_data(_data)
	_placeholders_ui.set_data(_data)
	_auto_translate_ui.set_data(_data)

func _update_view() -> void:
	_file_ui.text = _data.setting_path_to_file()

func _on_save_data() -> void:
	save_data(true)

func save_data(update_script_classes = false) -> void:
	_data.save_data_translations(update_script_classes)
	_data.save_data_remaps()

func _open_file() -> void:
	var file_dialog: FileDialog = LocalizationEditorDialogFile.instantiate()
	var root = get_tree().get_root()
	root.add_child(file_dialog)
	assert(file_dialog.file_selected.connect(_path_to_file_changed) == OK)
	file_dialog.popup_centered()

func _path_to_file_changed(new_path) -> void:
	_data.setting_path_to_file_put(new_path)
	var file = File.new()
	if file.file_exists(new_path):
		_load_data()
		_data_to_childs()
		_update_view()
