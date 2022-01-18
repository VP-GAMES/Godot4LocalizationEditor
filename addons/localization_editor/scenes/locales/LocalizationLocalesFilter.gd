# Locales filter for LocalizationEditor : MIT License
# @author Vladimir Petrenko
@tool
extends MarginContainer

var _data: LocalizationData

@onready var _filter_ui = $HBox/Filter as LineEdit
@onready var _selected_ui = $HBox/Selected as CheckBox

func set_data(data: LocalizationData) -> void:
	_data = data
	_init_connections()

func _init_connections() -> void:
	if not _filter_ui.is_connected("text_changed", _on_filter_changed):
		assert(_filter_ui.text_changed.connect(_on_filter_changed) == OK)
	if not _selected_ui.is_connected("toggled", _on_selected_changed):
		assert(_selected_ui.toggled.connect(_on_selected_changed) == OK)

func _on_filter_changed(text: String) -> void:
	_data.set_locales_filter(text)

func _on_selected_changed(value) -> void:
	_data.set_locales_selected(value)
