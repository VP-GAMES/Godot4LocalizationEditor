# Autotranslate Yandex (https://translate.yandex.com/) for LocalizationEditor : MIT License
# @author Vladimir Petrenko
@tool
extends MarginContainer

var ctx = HMACContext.new()

const uuid_gen = preload("res://addons/localization_editor/uuid/uuid.gd")

const SETTINGS_SAVE_TRANSLATOR_SELECTION = "localization_editor/translations_translator_selection"
const SETTINGS_SAVE_AUTH = "localization_editor/translations_save_auth"
const SETTINGS_SAVE_AUTH_DEEPL_KEY = "localization_editor/translations_save_auth_deepl_key"
const SETTINGS_SAVE_AUTH_MICROSOFT_URL = "localization_editor/translations_save_auth_microsoft_url"
const SETTINGS_SAVE_AUTH_MICROSOFT_LOCATION = "localization_editor/translations_save_auth_deepl_location"
const SETTINGS_SAVE_AUTH_MICROSOFT_KEY = "localization_editor/translations_save_auth_deepl_key"
const SETTINGS_SAVE_AUTH_AMAZON_REGION = "localization_editor/translations_save_auth_amazon_region"
const SETTINGS_SAVE_AUTH_AMAZON_ACCESS_KEY = "localization_editor/translations_save_auth_access_key"
const SETTINGS_SAVE_AUTH_AMAZON_SECRET_KEY = "localization_editor/translations_save_auth_secret_key"

var _data: LocalizationData
var _data_keys: Array = []
var _queries_count: int = 0
var _from_code: String
var _to_code: String

@onready var _translator: OptionButton = $Panel/VBox/HBoxTranslator/Translator
@onready var _link: LinkButton = $Panel/VBox/HBoxTranslator/LinkButton
@onready var _save_auth: CheckBox = $Panel/VBox/HBoxTranslator/SaveAuth
@onready var _from_language_ui = $Panel/VBox/HBox/FromLanguage 
@onready var _to_language_ui = $Panel/VBox/HBox/ToLanguage
@onready var _translate_ui: Button = $Panel/VBox/HBox/Translate
@onready var _progress_ui: ProgressBar = $Panel/VBox/Progress

# *** DEEPL ***
@onready var _deepl_container: HBoxContainer = $Panel/VBox/HBoxDeepL
@onready var _deepl_key: LineEdit = $Panel/VBox/HBoxDeepL/DeepLKey

# *** MICROSOFT AZURE ***
@onready var _microsoft_container: HBoxContainer = $Panel/VBox/HBoxMicrosoft
@onready var _microsoft_url: OptionButton = $Panel/VBox/HBoxMicrosoft/URL
@onready var _microsoft_location: LineEdit = $Panel/VBox/HBoxMicrosoft/Location
@onready var _microsoft_key: LineEdit = $Panel/VBox/HBoxMicrosoft/Key

# *** AMAZON AWS ***
@onready var _amazon_container: VBoxContainer = $Panel/VBox/VBoxAWS
@onready var _amazon_region: OptionButton = $Panel/VBox/VBoxAWS/HBoxRegion/Region
@onready var _amazon_access_key: LineEdit = $Panel/VBox/VBoxAWS/HBoxAccessKey/AccessKey
@onready var _amazon_secret_key: LineEdit = $Panel/VBox/VBoxAWS/HBoxSecretKey/SecretKey

const Locales = preload("res://addons/localization_editor/model/LocalizationLocalesList.gd")

func set_data(data: LocalizationData) -> void:
	_data = data
	var has_save_auth = ProjectSettings.get_setting(SETTINGS_SAVE_AUTH) == true
	_save_auth.set_pressed(has_save_auth)
	if has_save_auth:
		_translator.selected = ProjectSettings.get_setting(SETTINGS_SAVE_TRANSLATOR_SELECTION)
		_deepl_key.text = ProjectSettings.get_setting(SETTINGS_SAVE_AUTH_DEEPL_KEY)
		_microsoft_url.selected = ProjectSettings.get_setting(SETTINGS_SAVE_AUTH_MICROSOFT_URL)
		_microsoft_location.text = ProjectSettings.get_setting(SETTINGS_SAVE_AUTH_MICROSOFT_LOCATION)
		_microsoft_key.text = ProjectSettings.get_setting(SETTINGS_SAVE_AUTH_MICROSOFT_KEY)
		_amazon_region.selected = ProjectSettings.get_setting(SETTINGS_SAVE_AUTH_AMAZON_REGION)
		_amazon_access_key.text = ProjectSettings.get_setting(SETTINGS_SAVE_AUTH_AMAZON_ACCESS_KEY)
		_amazon_secret_key.text = ProjectSettings.get_setting(SETTINGS_SAVE_AUTH_AMAZON_SECRET_KEY)
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _data.is_connected("data_changed", _update_view):
		assert(_data.data_changed.connect(_update_view) == OK)
	if not _translator.is_connected("item_selected", _on_translator_selection_changed):
		_translator.item_selected.connect(_on_translator_selection_changed)
	if not _link.is_connected("pressed", _on_link_pressed):
		_link.pressed.connect(_on_link_pressed)
	if not _save_auth.toggled.is_connected(_on_save_auth_toggled):
		_save_auth.toggled.connect(_on_save_auth_toggled)
	if not _translate_ui.is_connected("pressed", _on_translate_pressed):
		assert(_translate_ui.connect("pressed", _on_translate_pressed) == OK)

	if not _deepl_key.text_changed.is_connected(_deepl_key_text_changed):
		_deepl_key.text_changed.connect(_deepl_key_text_changed)

	if not _amazon_region.item_selected.is_connected(_on_amazon_region_selection_changed):
		_amazon_region.item_selected.connect(_on_amazon_region_selection_changed)
	if not _amazon_access_key.text_changed.is_connected(_amazon_access_key_text_changed):
		_amazon_access_key.text_changed.connect(_amazon_access_key_text_changed)
	if not _amazon_secret_key.text_changed.is_connected(_amazon_secret_key_text_changed):
		_amazon_secret_key.text_changed.connect(_amazon_secret_key_text_changed)

	if not _microsoft_url.is_connected("item_selected", _on_microsoft_url_selection_changed):
		_microsoft_url.item_selected.connect(_on_microsoft_url_selection_changed)
	if not _microsoft_location.text_changed.is_connected(_microsoft_location_text_changed):
		_microsoft_location.text_changed.connect(_microsoft_location_text_changed)
	if not _microsoft_key.text_changed.is_connected(_microsoft_key_text_changed):
		_microsoft_key.text_changed.connect(_microsoft_key_text_changed)

func _on_save_auth_toggled(button_pressed: bool) -> void:
	_update_auth_settings()

func _deepl_key_text_changed(_new_text: String) -> void:
	_update_auth_settings()

func _microsoft_location_text_changed(_new_text: String) -> void:
	_update_auth_settings()

func _amazon_access_key_text_changed(_new_text: String) -> void:
	_update_auth_settings()

func _amazon_secret_key_text_changed(_new_text: String) -> void:
	_update_auth_settings()

func _on_amazon_region_selection_changed(index: int):
	_update_auth_settings()

func _on_microsoft_url_selection_changed(index: int):
	_update_auth_settings()

func _microsoft_key_text_changed(_new_text: String) -> void:
	_update_auth_settings()

func _update_auth_settings() -> void:
	ProjectSettings.set_setting(SETTINGS_SAVE_AUTH, _save_auth.button_pressed)
	if _save_auth.button_pressed:
		ProjectSettings.set_setting(SETTINGS_SAVE_TRANSLATOR_SELECTION, _translator.selected)
		ProjectSettings.set_setting(SETTINGS_SAVE_AUTH_DEEPL_KEY, _deepl_key.text)
		ProjectSettings.set_setting(SETTINGS_SAVE_AUTH_MICROSOFT_URL, _microsoft_url.selected)
		ProjectSettings.set_setting(SETTINGS_SAVE_AUTH_MICROSOFT_LOCATION, _microsoft_location.text)
		ProjectSettings.set_setting(SETTINGS_SAVE_AUTH_MICROSOFT_KEY, _microsoft_key.text)
		ProjectSettings.set_setting(SETTINGS_SAVE_AUTH_AMAZON_REGION, _translator.selected)
		ProjectSettings.set_setting(SETTINGS_SAVE_AUTH_AMAZON_ACCESS_KEY, _amazon_access_key.text)
		ProjectSettings.set_setting(SETTINGS_SAVE_AUTH_AMAZON_SECRET_KEY, _amazon_secret_key.text)
	else:
		ProjectSettings.set_setting(SETTINGS_SAVE_TRANSLATOR_SELECTION, null)
		ProjectSettings.set_setting(SETTINGS_SAVE_AUTH_DEEPL_KEY, null)
		ProjectSettings.set_setting(SETTINGS_SAVE_AUTH_MICROSOFT_URL, null)
		ProjectSettings.set_setting(SETTINGS_SAVE_AUTH_MICROSOFT_LOCATION, null)
		ProjectSettings.set_setting(SETTINGS_SAVE_AUTH_MICROSOFT_KEY, null)
		ProjectSettings.set_setting(SETTINGS_SAVE_AUTH_AMAZON_REGION, null)
		ProjectSettings.set_setting(SETTINGS_SAVE_AUTH_AMAZON_ACCESS_KEY, null)
		ProjectSettings.set_setting(SETTINGS_SAVE_AUTH_AMAZON_SECRET_KEY, null)
	ProjectSettings.save()

func _update_view() -> void:
	_init_from_language_ui()
	_check_translate_ui_selected()

func _init_from_language_ui() -> void:
	_from_language_ui.clear()
	if not _from_language_ui.is_connected("selection_changed", _check_translate_ui):
		assert(_from_language_ui.connect("selection_changed", _check_translate_ui) == OK)
	for loc in _data.locales():
		var label = Locales.label_by_code(loc)
		if label != null and not label.is_empty():
			_from_language_ui.add_item(DropdownItem.new(loc, label))

func _init_to_language_ui(locales: Dictionary) -> void:
	_to_language_ui.clear()
	if not _to_language_ui.is_connected("selection_changed", _check_translate_ui):
		assert(_to_language_ui.connect("selection_changed", _check_translate_ui) == OK)
	for locale in locales:
		if Locales.has_code(locale):
			_to_language_ui.add_item(DropdownItem.new(locale, Locales.label_by_code(locale)))

func _check_translate_ui(_item: DropdownItem) -> void:
	_check_translate_ui_selected()

func _check_translate_ui_selected() -> void:
	if _translator.selected != -1:
		_on_translator_selected(_translator.selected)
	_check_translate_ui_disabled()

func _check_translate_ui_disabled() -> void:
	_translate_ui.set_disabled(_from_language_ui.get_selected_index() == -1 or _to_language_ui.get_selected_index() == -1)

func _on_translator_selection_changed(index: int) -> void:
	_to_language_ui.clear_selection()
	_on_translator_selected(index)
	_update_auth_settings()

func _on_translator_selected(index: int) -> void:
	_deepl_container.hide()
	_amazon_container.hide()
	_microsoft_container.hide()
	_check_translate_ui_disabled()
	match index:
		0:
			_link.text =  "https://translate.google.com/"
			_init_to_language_ui(LocalizationAutoTranslateGoogle.LOCALES)
		1:
			_link.text =  "https://yandex.com/dev/translate/"
			_init_to_language_ui(LocalizationAutoTranslateYandex.LOCALES)
		2:
			_link.text =  "https://www.deepl.com/translator"
			_init_to_language_ui(LocalizationAutoTranslateDeepL.LOCALES)
			_deepl_container.show()
		3:
			_link.text =  "https://aws.amazon.com/translate/"
			_init_to_language_ui(LocalizationAutoTranslateAmazon.LOCALES)
			_amazon_container.show()
		4:
			_link.text =  "https://translator.microsoft.com/"
			_init_to_language_ui(LocalizationAutoTranslateMicrosoft.LOCALES)
			_microsoft_container.show()

func _on_link_pressed() -> void:
	OS.shell_open(_link.text)

func _on_translate_pressed() -> void:
	_from_code = _from_language_ui.get_selected_value()
	_from_code = _from_code.to_lower()
	_to_code = _to_language_ui.get_selected_value()
	_to_code = _to_code.to_lower()
	_translate()

func _translate() -> void:
	_data_keys = _data.keys().duplicate()
	var from_translation = _data.translation_by_locale(_data_keys[0], _from_code)
	var to_translation = _data.translation_by_locale(_data_keys[0], _to_code)
	_translate_ui.disabled = true
	_progress_ui.max_value = _data.keys().size()
	if not _data.locales().has(_to_code):
		_data.add_locale(_to_code, false)
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
	http_request.request(url, [], HTTPClient.Method.METHOD_GET)

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
	var key = _deepl_key.text
	var text = "text=" + from_translation.value.uri_encode() + "&target_lang=" + to_translation.locale
	var url = "https://api-free.deepl.com/v2/translate"
	var http_request = HTTPRequest.new()
	http_request.timeout = 5
	add_child(http_request)
	assert(http_request.request_completed.connect(_http_request_completed_deepl.bind(http_request, from_translation, to_translation)) == OK)
	var custom_headers = [
		"Host: api-free.deepl.com",
		"Authorization: DeepL-Auth-Key " + key,
		"User-Agent: YourApp/1.2.3",
		"Content-Length: " + str(text.length()),
		"Content-Type: application/x-www-form-urlencoded"
	]
	http_request.request(url, custom_headers, HTTPClient.Method.METHOD_POST, text)

func _http_request_completed_deepl(result, response_code, headers, body: PackedByteArray, http_request, from_translation, to_translation):
	var json = JSON.new()
	var result_body := json.parse(body.get_string_from_utf8())
	if json.get_data() != null:
		if not json.get_data().has("translations"):
			push_error("FROM: ", from_translation.value, " => ", body.get_string_from_utf8())
		to_translation.value = json.get_data().translations[0].text
		_add_progress()
		remove_child(http_request)
	_queries_count -= 1
	_create_requests()
# *** DEEPL IMPLEMENTATION END ***

# *** AMAZON IMPLEMENTATION START ***
func _create_request_amazon(from_translation, to_translation) -> void:
	var method = "POST"
	var service = "translate"
	var region = "us-east-2"
	match _amazon_region.selected:
		1:
			region = "us-east-1"
		2:
			region = "us-west-1"
		3:
			region = "us-west-2"
		4:
			region = "ap-east-1"
		5:
			region = "ap-south-1"
		6:
			region = "ap-northeast-2"
		7:
			region = "ap-southeast-1"
		8:
			region = "ap-southeast-2"
		9:
			region = "ap-northeast-1"
		10:
			region = "ca-central-1"
		11:
			region = "eu-central-1"
		12:
			region = "eu-west-1"
		13:
			region = "eu-west-2"
		14:
			region = "eu-west-3"
		15:
			region = "eu-north-1"
		16:
			region = "us-gov-west-1"
	var host = service + "." + region + ".amazonaws.com"
	var endpoint = "https://" + host + "/"
	var content_type = "application/x-amz-json-1.1"
	var amz_target = "AWSShineFrontendService_20170701.TranslateText"

	var request_parameters = '{'
	request_parameters += '"Text": "' + from_translation.value + '",'
	request_parameters += '"SourceLanguageCode": "' + from_translation.locale + '",'
	request_parameters += '"TargetLanguageCode": "' + to_translation.locale + '"'
	request_parameters += '}'

	# https://us-east-1.console.aws.amazon.com/iam/
	var access_key = _amazon_access_key.text
	var secret_key = _amazon_secret_key.text

	var amz_date = Time.get_datetime_string_from_system(true).replace("-", "").replace(":", "") + "Z"
	var date_stamp = Time.get_date_string_from_system(true).replace("-", "")
	var canonical_uri = "/"
	var canonical_querystring = ""
	var canonical_headers = "content-type:" + content_type + "\n" + "host:" + host + "\n" + "x-amz-date:" + amz_date + "\n" + "x-amz-target:" + amz_target + "\n"
	var signed_headers = "content-type;host;x-amz-date;x-amz-target"

	var payload_hash = request_parameters.sha256_text()
	var canonical_request = method + "\n" + canonical_uri + "\n" + canonical_querystring + "\n" + canonical_headers + "\n" + signed_headers + "\n" + payload_hash
	var algorithm = "AWS4-HMAC-SHA256"
	var credential_scope = date_stamp + "/" + region + "/" + service + "/" + "aws4_request"
	var string_to_sign = algorithm + "\n" +  amz_date + "\n" +  credential_scope + "\n" +  canonical_request.sha256_text()

	var signing_key = getSignatureKey(secret_key, date_stamp, region, service)
	var signature = signing_hex(signing_key, string_to_sign)
	var authorization_header = algorithm + " " + "Credential=" + access_key + "/" + credential_scope + ", " +  "SignedHeaders=" + signed_headers + ", " + "Signature=" + signature
	
	var http_request = HTTPRequest.new()
	http_request.timeout = 5
	add_child(http_request)
	assert(http_request.request_completed.connect(_http_request_completed_amazon.bind(http_request, from_translation, to_translation)) == OK)
	var headers = [
		"Content-type: application/x-amz-json-1.1",
		"X-Amz-Date: " + amz_date,
		"X-Amz-Target: " + amz_target,
		"Authorization: " + authorization_header
	]
	var error = http_request.request(endpoint, headers, HTTPClient.Method.METHOD_POST, request_parameters)

func getSignatureKey(key, dateStamp, regionName, serviceName):
	var kDate = signing(("AWS4" + key).to_utf8_buffer(), dateStamp)
	var kRegion = signing(kDate, regionName)
	var kService = signing(kRegion, serviceName)
	return signing(kService, "aws4_request")

func signing(key: PackedByteArray, msg: String):
	assert(ctx.start(HashingContext.HASH_SHA256, key) == OK)
	assert(ctx.update(msg.to_utf8_buffer()) == OK)
	var hmac = ctx.finish()
	return hmac

func signing_hex(key: PackedByteArray, msg: String) -> String:
	assert(ctx.start(HashingContext.HASH_SHA256, key) == OK)
	assert(ctx.update(msg.to_utf8_buffer()) == OK)
	var hmac = ctx.finish()
	return hmac.hex_encode()

func _http_request_completed_amazon(result, response_code, headers, body: PackedByteArray, http_request, from_translation, to_translation):
	var json = JSON.new()
	var result_body := json.parse(body.get_string_from_utf8())
	if json.get_data() != null:
		if not json.get_data().has("TranslatedText"):
			push_error("FROM: ", from_translation.value, " => ", body.get_string_from_utf8())
		to_translation.value = json.get_data().TranslatedText
		_add_progress()
		remove_child(http_request)
	_queries_count -= 1
	_create_requests()

# *** AMAZON IMPLEMENTATION END ***

# *** MICROSOFT IMPLEMENTATION START ***
func _create_request_microsoft(from_translation, to_translation) -> void:
	var key = _microsoft_key.text
	var location = _microsoft_location.text
	var endpoint = "https://api.cognitive.microsofttranslator.com"
	match _microsoft_url.selected:
		1:
			endpoint = "https://api-apc.congnitive.microsofttranslator.com"
		2:
			endpoint = "https://api-eur.congnitive.microsofttranslator.com"
		3:
			endpoint = "https://api-nam.congnitive.microsofttranslator.com"
	var route = "/translate?api-version=3.0&from=en&to=ru"
	var http_request = HTTPRequest.new()
	http_request.timeout = 5
	add_child(http_request)
	assert(http_request.request_completed.connect(_http_request_completed_microsoft.bind(http_request, from_translation, to_translation)) == OK)
	var custom_headers = [
		"Ocp-Apim-Subscription-Key: " + key,
		"Ocp-Apim-Subscription-Region: " + location,
		"Content-type: application/json",
		"X-ClientTraceId: " + uuid_gen.v4()
	]
	var url = endpoint + route
	var body = JSON.stringify([{"Text": from_translation.value}])
	var error = http_request.request(url, custom_headers, HTTPClient.Method.METHOD_POST, body)

func _http_request_completed_microsoft(result, response_code, headers, body: PackedByteArray, http_request, from_translation, to_translation):
	var json = JSON.new()
	var result_body := json.parse(body.get_string_from_utf8())
	if json.get_data() != null:
		if not json.get_data()[0].has("translations"):
			push_error("FROM: ", from_translation.value, " => ", body.get_string_from_utf8())
		to_translation.value = json.get_data()[0].translations[0].text
		_add_progress()
		remove_child(http_request)
	_queries_count -= 1
	_create_requests()
# *** MICROSOFT IMPLEMENTATION END ***

func _add_progress() -> void:
	_progress_ui.value = _progress_ui.value + 1
	_check_progress()

func _check_progress() -> void:
	if _progress_ui.value == _data.keys().size():
		_data.emit_signal_data_changed()
		_translate_ui.disabled = false
		_progress_ui.value = 0
