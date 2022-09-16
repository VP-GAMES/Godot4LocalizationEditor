# Translation UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
@tool
extends MarginContainer

var _key
var _locale
var _translation
var _data: LocalizationData

var _translation_ui_style_empty: StyleBoxFlat

@onready var _translation_ui = $HBox/Translation

func set_data(key, translation, locale, data: LocalizationData) -> void:
	_key = key
	_translation = translation
	_locale = locale
	_data = data
	_draw_view()

func _ready() -> void:
	_init_styles()
	_init_connections()

func _init_styles() -> void:
	var style_box = _translation_ui.get_theme_stylebox("normal", "LineEdit")
	_translation_ui_style_empty = style_box.duplicate()
	_translation_ui_style_empty.set_bg_color(Color("#661c1c"))

func _init_connections() -> void:
	if not _translation_ui.is_connected("text_changed", _on_text_changed):
		assert(_translation_ui.text_changed.connect(_on_text_changed) == OK)

func _draw_view() -> void:
	_translation_ui.text = _translation.value
	_check_translation_ui()

func _on_text_changed(new_text) -> void:
	_translation.value = new_text
	_check_translation_ui()

func _check_translation_ui() -> void:
	if _translation_ui.text.length() <= 0:
		_translation_ui.set("custom_styles/normal", _translation_ui_style_empty)
		_translation_ui.tooltip_text =  "Please enter value for your translation"
	else:
		_translation_ui.set("custom_styles/normal", null)
		_translation_ui.tooltip_text =  ""
