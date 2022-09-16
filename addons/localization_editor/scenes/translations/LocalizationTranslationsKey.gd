# Translations key UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
@tool
extends MarginContainer

var _key
var _data: LocalizationData

var _key_ui_style_empty: StyleBoxFlat
var _key_ui_style_double: StyleBoxFlat

@onready var _add_ui = $HBoxContainer/Add as Button
@onready var _del_ui = $HBoxContainer/Del as Button
@onready var _key_ui = $HBoxContainer/Key as LineEdit

func key():
	return _key

func set_data(key, data: LocalizationData):
	_key = key
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()

func _init_styles() -> void:
	var style_box = _key_ui.get_theme_stylebox("normal", "LineEdit")
	_key_ui_style_empty = style_box.duplicate()
	_key_ui_style_empty.set_bg_color(Color("#661c1c"))
	_key_ui_style_double = style_box.duplicate()
	_key_ui_style_double.set_bg_color(Color("#192e59"))

func _init_connections() -> void:
	if not _add_ui.is_connected("pressed", _add_pressed):
		assert(_add_ui.connect("pressed", _add_pressed) == OK)
	if not _del_ui.is_connected("pressed", _del_pressed):
		assert(_del_ui.connect("pressed", _del_pressed) == OK)
	if not _key_ui.is_connected("text_changed", _key_value_changed):
		assert(_key_ui.text_changed.connect(_key_value_changed) == OK)
	if not _data.is_connected("data_key_value_changed", _check_key_ui):
		assert(_data.connect("data_key_value_changed", _check_key_ui) == OK)

func _draw_view() -> void:
	_key_ui.text = _key.value
	_check_key_ui()
	_update_del_view()

func _update_del_view():
	_del_ui.disabled = _data.keys().size() == 1

func _add_pressed() -> void:
	_data.add_key_new_after_uuid(_key.uuid)

func _del_pressed() -> void:
	_data.del_key(_key.uuid)

func _key_value_changed(key_value) -> void:
	_data.key_value_change(_key, key_value)

func _check_key_ui_text() -> void:
	if _key_ui.text != _key.value:
		_key_ui.text = _key.value

func _check_key_ui() -> void:
	if _key_ui.text.length() <= 0:
		_key_ui.set("custom_styles/normal", _key_ui_style_empty)
		_key_ui.tooltip_text =  "Please enter a key name"
	elif _data.is_key_value_double(_key_ui.text):
		_key_ui.tooltip_text =  "Keyname already exists"
		_key_ui.set("custom_styles/normal", _key_ui_style_double)
	else:
		_key_ui.set("custom_styles/normal", null)
		_key_ui.tooltip_text =  ""
