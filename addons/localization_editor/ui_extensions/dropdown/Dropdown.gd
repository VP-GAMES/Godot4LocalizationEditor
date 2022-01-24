# UI Extension Filter Dropdown : MIT License
# @author Vladimir Petrenko
@tool
extends LineEdit
class_name DropdownCustom

signal selection_changed

var selected = -1
@export var popup_maxheight_count: int = 10

var _group = ButtonGroup.new()
var _filter: String = ""
var _items: Array[String] = []

@onready var _popup_panel: PopupPanel= $PopupPanel
@onready var _popup_panel_vbox: VBoxContainer= $PopupPanel/Scroll/VBox

const DropdownCheckBox = preload("DropdownCheckBox.tscn")

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton) and event.pressed:
		var evLocal = make_input_local(event)
		if !Rect2(Vector2(0,0),rect_size).has_point(evLocal.position):
			if selected < 0:
				text = ""
			else:
				text = _items[selected]
			set_caret_column(text.length())
			_filter = text
			_popup_panel.hide()

func clear() -> void:
	_items.clear()

func items() -> Array[String]:
	return _items

func add_item(value: String) -> void:
	_items.append(value)

func get_selected() -> int:
	return selected

func _ready() -> void:
	_group.resource_local_to_scene = false
	_init_connections()

func _init_connections() -> void:
	assert(_popup_panel.popup_hide.connect(_popup_panel_hide) == OK)
	assert(gui_input.connect(_line_edit_gui_input) == OK)

func _popup_panel_hide() -> void:
	if text_changed.is_connected(_on_text_changed):
		text_changed.disconnect(_on_text_changed)
 
func _popup_panel_focus_entered() -> void:
	grab_focus()

func _popup_panel_index_pressed(index: int) -> void:
	var le_text = _popup_panel.get_item_text(index)
	text = le_text
	_filter = text
	selected = _items.find(text)

func _line_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_update_popup_view()
			if not text_changed.is_connected(_on_text_changed):
				assert(text_changed.connect(_on_text_changed) == OK)

func _on_text_changed(filter: String) -> void:
	_filter = filter
	_update_popup_view()

func _update_popup_view() -> void:
	if not editable:
		return
	_update_items_view()
	var rect = get_global_rect()
	var position =  Vector2(rect.position.x, rect.position.y + rect.size.y)
	if Engine.is_editor_hint():
		position = get_viewport().canvas_transform * rect_global_position + Vector2(get_viewport().position)
		position.y += rect_size.y
	_popup_panel.position = position
	_popup_panel.popup()
	var size = Vector2(rect.size.x, _popup_calc_height())
	_popup_panel.set_size(size)
	grab_focus()

func _popup_calc_height() -> int:
	var child_count = _popup_panel_vbox.get_child_count() 
	if child_count > 0:
		var single_height: int = _popup_panel_vbox.get_child(0).rect_size.y
		if child_count >= popup_maxheight_count:
			return popup_maxheight_count * single_height
		else:
			return child_count * single_height
	return 0

func _update_items_view() -> void:
	for child in _popup_panel_vbox.get_children():
		_popup_panel_vbox.remove_child(child)
		child.queue_free()
	for index in range(_items.size()):
		if _filter.length() <= 0:
			_popup_panel_vbox.add_child(_init_check_box(index))
		else:
			if _filter in _items[index]:
				_popup_panel_vbox.add_child(_init_check_box(index))

func _init_check_box(index: int) -> CheckBox:
	var check_box = DropdownCheckBox.instantiate()
	check_box.set_button_group(_group)
	check_box.text = _items[index]
	if index == selected:
		check_box.set_pressed(true)
	check_box.connect("pressed", _on_selection_changed, [index])
	return check_box

func _on_selection_changed(index: int) -> void:
	if selected != index:
		selected = index
		_filter = _items[selected]
		text = _filter
		emit_signal("selection_changed")
	_popup_panel.hide()
