# Locale UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
@tool
extends MarginContainer

var _locale
var _data: LocalizationData

@onready var _selection_ui = $HBox/Selection as CheckBox
@onready var _locale_ui = $HBox/Locale as Label
@onready var _eye_ui = $HBox/Eye as TextureButton

const IconOpen = preload("res://addons/localization_editor/icons/Open.svg")
const IconClose = preload("res://addons/localization_editor/icons/Close.svg")

func locale():
	return _locale

func set_data(locale, data: LocalizationData) -> void:
	_locale = locale
	_data = data
	_draw_view()
	_init_connections()

func _draw_view() -> void:
	_selection_ui.text = _locale.code
	_locale_ui.text = _locale.name
	_selection_ui_state()
	_eye_ui_state()

func _selection_ui_state() -> void:
	_selection_ui.set_pressed(_data.find_locale(_locale.code) != null)

func _eye_ui_state() -> void:
	_eye_ui.set_pressed(not _data.is_locale_visible(_locale.code))
	_update_view_eye(_selection_ui.is_pressed())

func _init_connections() -> void:
	if not _selection_ui.is_connected("toggled", _on_selection_changed):
		assert(_selection_ui.toggled.connect(_on_selection_changed) == OK)
	if not _eye_ui.is_connected("toggled", _on_eye_changed):
		assert(_eye_ui.toggled.connect(_on_eye_changed) == OK)

func _on_selection_changed(value) -> void:
	if value == true:
		_data.add_locale(_locale.code)
		_update_view_eye(value)
	else:
		_show_confirm_dialog()

func _show_confirm_dialog() -> void:
		var root = get_tree().get_root()
		var confirm_dialog  = ConfirmationDialog.new()
		confirm_dialog.title = "Confirm"
		confirm_dialog.dialog_text = "Are you sure to delete locale with all translations and remaps?"
		confirm_dialog.confirmed.connect(_on_confirm_dialog_ok,  [root, confirm_dialog])
		confirm_dialog.cancelled.connect(_on_confirm_dialog_cancelled, [root, confirm_dialog])
		root.add_child(confirm_dialog)
		confirm_dialog.popup_centered()

func _on_confirm_dialog_ok(root, confirm_dialog) -> void:
	_data.del_locale(_locale.code)
	_update_view_eye(false)
	_confirm_dialog_remove(root, confirm_dialog)

func _on_confirm_dialog_cancelled(root, confirm_dialog) -> void:
	_selection_ui.set_pressed(true)
	_confirm_dialog_remove(root, confirm_dialog)

func _confirm_dialog_remove(root, confirm_dialog) -> void:
	root.remove_child(confirm_dialog)
	confirm_dialog.queue_free()

func _update_view_eye(value: bool) -> void:
	if value:
		_eye_ui.show()
		_update_visible_icon_from_data()
	else:
		_eye_ui.hide()

func _update_visible_icon_from_data() -> void:
	_update_visible_icon(_data.is_locale_visible(_locale.code))

func _on_eye_changed(value) -> void:
	if value:
		_data.setting_locales_visibility_put(_locale.code)
	else:
		_data.setting_locales_visibility_del(_locale.code)
	_update_visible_icon(!value)

func _update_visible_icon(value: bool) -> void:
	_eye_ui.texture_normal = IconOpen if value else IconClose
