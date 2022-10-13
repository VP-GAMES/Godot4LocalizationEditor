# Autotranslate Yandex (https://translate.yandex.com/) for LocalizationEditor : MIT License
# @author Vladimir Petrenko
@tool
extends MarginContainer

var _data: LocalizationData
var _data_keys: Array = []
var _queries_count: int = 0
var _from_code: String
var _to_code: String

@onready var _translator: OptionButton = $Panel/VBox/HBoxTranslator/Translator
@onready var _link: LinkButton = $Panel/VBox/HBoxConnection/LinkButton
@onready var _from_language_ui = $Panel/VBox/HBox/FromLanguage 
@onready var _to_language_ui = $Panel/VBox/HBox/ToLanguage
@onready var _translate_ui: Button = $Panel/VBox/HBox/Translate
@onready var _progress_ui: ProgressBar = $Panel/VBox/Progress

const Locales = preload("res://addons/localization_editor/model/LocalizationLocalesList.gd")

func set_data(data: LocalizationData) -> void:
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _data.is_connected("data_changed", _update_view):
		assert(_data.data_changed.connect(_update_view) == OK)
	if not _translator.is_connected("item_selected", _on_translator_selected):
		_translator.item_selected.connect(_on_translator_selected)
	if not _link.is_connected("pressed", _on_link_pressed):
		_link.pressed.connect(_on_link_pressed)
	if not _translate_ui.is_connected("pressed", _on_translate_pressed):
		assert(_translate_ui.connect("pressed", _on_translate_pressed) == OK)

func _update_view() -> void:
	_init_from_language_ui()
	_check_translate_ui_selected()

func _init_from_language_ui() -> void:
	_from_language_ui.clear()
	if not _from_language_ui.is_connected("selection_changed", _check_translate_ui):
		assert(_from_language_ui.connect("selection_changed", _check_translate_ui) == OK)
	for loc in _data.locales():
		var locale = Locales.by_code(loc)
		if locale != null:
			_from_language_ui.add_item(DropdownItem.new(locale.name, locale.code))

func _init_to_language_ui(locales: Array) -> void:
	_to_language_ui.clear()
	if not _to_language_ui.is_connected("selection_changed", _check_translate_ui):
		assert(_to_language_ui.connect("selection_changed", _check_translate_ui) == OK)
	for locale in locales:
		if Locales.has_code(locale.code):
			_to_language_ui.add_item(DropdownItem.new(locale.name, locale.code))

func _check_translate_ui(_item: DropdownItem) -> void:
	_check_translate_ui_selected()

func _check_translate_ui_selected() -> void:
	if _translator.selected != -1:
		_on_translator_selected(_translator.selected)
	_check_translate_ui_disabled()

func _check_translate_ui_disabled() -> void:
	_translate_ui.set_disabled(_from_language_ui.get_selected_index() == -1 or _to_language_ui.get_selected_index() == -1)

func _on_translator_selected(index: int) -> void:
	_to_language_ui.clear_selection()
	_check_translate_ui_disabled()
	match index:
		0:
			_link.text =  "https://translate.google.com/"
			_init_to_language_ui(LocalizationAutoTranslateGoogle.locales())
		1:
			_link.text =  "https://yandex.com/dev/translate/"
			_init_to_language_ui(LocalizationAutoTranslateYandex.locales())
		2:
			_link.text =  "https://www.deepl.com/translator"
			_init_to_language_ui(LocalizationAutoTranslateDeepL.locales())
		3:
			_link.text =  "https://aws.amazon.com/translate/"
			_init_to_language_ui(LocalizationAutoTranslateAmazon.locales())
		4:
			_link.text =  "https://translator.microsoft.com/"
			_init_to_language_ui(LocalizationAutoTranslateMicrosoft.locales())

func _on_link_pressed() -> void:
	OS.shell_open(_link.text)

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
			match _translator.selected:
				0:
					_create_request_google(from_translation, to_translation)
				1:
					_create_request_yandex(from_translation, to_translation)
				2:
					_create_request_deepl(from_translation, to_translation)
				3:
					_create_request_amazon(from_translation, to_translation)
				4:
					_create_request_microsoft(from_translation, to_translation)
		else:
			_add_progress()
		_data_keys.remove_at(0)
		_queries_count += 1

# *** GOOGLE IMPLEMENTATION START ***
func _create_request_google(from_translation, to_translation) -> void:
	var url = _create_url_google(from_translation, to_translation)
	var http_request = HTTPRequest.new()
	http_request.timeout = 5
	add_child(http_request)
	assert(http_request.request_completed.connect(_http_request_completed_google.bind(http_request, to_translation)) == OK)
	http_request.request(url, [], false, HTTPClient.METHOD_GET)

func _create_url_google(from_translation, to_translation) -> String:
	var url = "https://translate.googleapis.com/translate_a/single?client=gtx"
	url += "&sl=" + from_translation.locale
	url += "&tl=" + to_translation.locale
	url += "&dt=t"
	url += "&q=" + from_translation.value.uri_encode()
	return url

func _http_request_completed_google(result, response_code, headers, body, http_request, to_translation):
	var json = JSON.new()
	var result_body := json.parse(body.get_string_from_utf8())
	if json.get_data() != null:
		var value = ""
		for index in range(json.get_data()[0].size()):
			if index == 0:
				value = json.get_data()[0][index][0]
			else:
				value += " " + json.get_data()[0][index][0]
		to_translation.value = value
		_add_progress()
		remove_child(http_request)
	_queries_count -= 1
	_create_requests()
# *** GOOGLE IMPLEMENTATION END ***

# *** YANDEX IMPLEMENTATION START ***
func _create_request_yandex(from_translation, to_translation) -> void:
	push_error("YANDEX IMPLEMENTATION NOT SUPPORTED YET")
	return
# *** YANDEX IMPLEMENTATION END ***

# *** DEEPL IMPLEMENTATION START ***
func _create_request_deepl(from_translation, to_translation) -> void:
	push_error("DEEPL IMPLEMENTATION NOT SUPPORTED YET")
	return
#POST /v2/translate HTTP/2
#Host: api-free.deepl.com
#Authorization: DeepL-Auth-Key [yourAuthKey]
#User-Agent: YourApp/1.2.3
#Content-Length: 37
#Content-Type: application/x-www-form-urlencoded

#text=Hello%2C%20world!&target_lang=DE
	
	var url = "https://api-free.deepl.com/v2/translate"
	var http_request = HTTPRequest.new()
	http_request.timeout = 5
	add_child(http_request)
	assert(http_request.request_completed.connect(_http_request_completed_deepl.bind(http_request, to_translation)) == OK)
	http_request.request(url, [], false, HTTPClient.METHOD_POST)

func _http_request_completed_deepl(result, response_code, headers, body, http_request, to_translation):
	var json = JSON.new()
	var result_body := json.parse(body.get_string_from_utf8())
	if json.get_data() != null:
		var value = ""
		for index in range(json.get_data()[0].size()):
			if index == 0:
				value = json.get_data()[0][index][0]
			else:
				value += " " + json.get_data()[0][index][0]
		to_translation.value = value
		_add_progress()
		remove_child(http_request)
	_queries_count -= 1
	_create_requests()
# *** DEEPL IMPLEMENTATION END ***

# *** AMAZON IMPLEMENTATION START ***
func _create_request_amazon(from_translation, to_translation) -> void:
	push_error("AMAZON IMPLEMENTATION NOT SUPPORTED YET")
	return
# *** AMAZON IMPLEMENTATION END ***

# *** MICROSOFT IMPLEMENTATION START ***
func _create_request_microsoft(from_translation, to_translation) -> void:
	push_error("MICROSOFT IMPLEMENTATION NOT SUPPORTED YET")
	return
# *** MICROSOFT IMPLEMENTATION END ***

func _add_progress() -> void:
	_progress_ui.value = _progress_ui.value + 1
	_check_progress()

func _check_progress() -> void:
	if _progress_ui.value == _data.keys().size():
		_data.emit_signal_data_changed()
		_translate_ui.disabled = false
		_progress_ui.value = 0

