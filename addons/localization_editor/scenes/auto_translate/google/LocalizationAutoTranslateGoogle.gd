# Autotranslate Yandex (https://translate.yandex.com/) for LocalizationEditor : MIT License
# @author Vladimir Petrenko
@tool
extends MarginContainer

var _data: LocalizationData
var _data_keys: Array = []
var _queries_count: int = 0
var _from_code: String
var _to_code: String

@onready var _from_language_ui = $Panel/VBox/HBox/FromLanguage 
@onready var _to_language_ui = $Panel/VBox/HBox/ToLanguage
@onready var _translate_ui: Button = $Panel/VBox/HBox/Translate
@onready var _progress_ui: ProgressBar = $Panel/VBox/Progress

const Locales = preload("res://addons/localization_editor/model/LocalizationLocalesList.gd")
const GoogleLocales = preload("res://addons/localization_editor/scenes/auto_translate/google/LocalizationAutoTranslateGoogleLocalesList.gd")

func set_data(data: LocalizationData) -> void:
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _data.is_connected("data_changed", _update_view):
		assert(_data.data_changed.connect(_update_view) == OK)
	if not _translate_ui.is_connected("pressed", _on_translate_pressed):
		assert(_translate_ui.connect("pressed", _on_translate_pressed) == OK)

func _update_view() -> void:
	_init_from_language_ui()
	_init_to_language_ui()

func _init_from_language_ui() -> void:
	_from_language_ui.clear()
	if not _from_language_ui.is_connected("selection_changed", _check_translate_ui):
		assert(_from_language_ui.connect("selection_changed", _check_translate_ui) == OK)
	for loc in _data.locales():
		var locale = Locales.by_code(loc)
		if locale != null:
			_from_language_ui.add_item(DropdownItem.new(locale.name, locale.code))

func _init_to_language_ui() -> void:
	_to_language_ui.clear()
	if not _to_language_ui.is_connected("selection_changed", _check_translate_ui):
		assert(_to_language_ui.connect("selection_changed", _check_translate_ui) == OK)
	for locale in GoogleLocales.locales():
		if Locales.has_code(locale.code):
			_to_language_ui.add_item(DropdownItem.new(locale.name, locale.code))

func _check_translate_ui(_item: DropdownItem) -> void:
	_translate_ui.set_disabled(_from_language_ui.get_selected_index() == -1 or _to_language_ui.get_selected_index() == -1)

func _on_translate_pressed() -> void:
	_from_code = _from_language_ui.get_selected_value()
	_to_code = _to_language_ui.get_selected_value()
	_translate()

func _translate() -> void:
	_translate_ui.disabled = true
	_progress_ui.max_value = _data.keys().size()
	if not _data.locales().has(_to_code):
		_data.add_locale(_to_code, false)

	_data_keys = _data.keys().duplicate()
	_create_requests()

func _create_requests() -> void:
	var space = IP.RESOLVER_MAX_QUERIES - _queries_count
	for index in range(space):
		if _data_keys.size() <= 0:
			return
		var from_translation = _data.translation_by_locale(_data_keys[0], _from_code)
		var to_translation = _data.translation_by_locale(_data_keys[0], _to_code)
		if from_translation != null and not from_translation.value.is_empty() and (to_translation.value == null or to_translation.value.is_empty()):
			_create_request(from_translation, to_translation)
		else:
			_add_progress()
		_data_keys.remove_at(0)
		_queries_count += 1

func _create_request(from_translation, to_translation) -> void:
	var url = _create_url(from_translation, to_translation)
	var http_request = HTTPRequest.new()
	http_request.timeout = 5
	add_child(http_request)
	assert(http_request.request_completed.connect(_http_request_completed, [http_request, to_translation]) == OK)
	http_request.request(url, [], false, HTTPClient.METHOD_GET)

func _create_url(from_translation, to_translation) -> String:
	var url = "https://translate.googleapis.com/translate_a/single?client=gtx"
	url += "&sl=" + from_translation.locale
	url += "&tl=" + to_translation.locale
	url += "&dt=t"
	url += "&q=" + from_translation.value.uri_encode()
	return url

func _http_request_completed(result, response_code, headers, body, http_request, to_translation):
	var json = JSON.new()
	var result_body := json.parse(body.get_string_from_utf8())
	if json.get_data() != null:
		to_translation.value = json.get_data()[0][0][0]
		_add_progress()
		remove_child(http_request)
	_queries_count -= 1
	_create_requests()

func _add_progress() -> void:
	_progress_ui.value = _progress_ui.value + 1
	_check_progress()

func _check_progress() -> void:
	if _progress_ui.value == _data.keys().size():
		_data.emit_signal_data_changed()
		_translate_ui.disabled = false
		_progress_ui.value = 0

