# Locales UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
@tool
extends MarginContainer

var _data: LocalizationData

@onready var _locales_ui = $Panel/Scroll/VBox as VBoxContainer

const LocalizationLocale = preload("res://addons/localization_editor/scenes/locales/LocalizationLocale.tscn")

func set_data(data: LocalizationData) -> void:
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _data.is_connected("data_changed", _update_view):
		assert(_data.data_changed.connect(_update_view) == OK)

func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	for child in _locales_ui.get_children():
		_locales_ui.remove_child(child)
		child.queue_free()

func _draw_view() -> void:
	for code in LocalizationLocalesList.Locales.keys():
		if _is_locale_to_show(code):
			var locale_ui = LocalizationLocale.instantiate()
			_locales_ui.add_child(locale_ui)
			locale_ui.set_data(code, _data)

func _is_locale_to_show(code) -> bool:
	if not _is_locale_to_show_by_selection(code):
		return false
	return _is_locale_to_show_by_filter(code)
	
func _is_locale_to_show_by_selection(code) -> bool:
	return !_data.locales_selected() or _data.find_locale(code) != null
		
func  _is_locale_to_show_by_filter(code) -> bool:
	var filter = _data.locales_filter()
	return filter == "" or filter in code or filter in LocalizationLocalesList.Locales[code]
