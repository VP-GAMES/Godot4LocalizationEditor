# UI Extension Filter Dropdown : MIT License
# @author Vladimir Petrenko
@tool
extends HBoxContainer
class_name DropdownCustom

signal selection_changed

var selected = -1
@export var popup_maxheight_count: int = 10

var _group = ButtonGroup.new()
var _filter: String = ""
var _items: Array[String] = []

@onready var _line_edit: LineEdit= $LineEdit
@onready var _popup_panel: PopupPanel= $PopupPanel
@onready var _popup_panel_vbox: VBoxContainer= $PopupPanel/Scroll/VBox

const DropdownCheckBox = preload("DropdownCheckBox.tscn")

func _input(event: InputEvent) -> void:
	if _line_edit != null and (event is InputEventMouseButton) and event.pressed:
		var evLocal = make_input_local(event)
		if !Rect2(Vector2(0,0),rect_size).has_point(evLocal.position):
			if selected < 0:
				_line_edit.text = ""
			else:
				_line_edit.text = _items[selected]
			_filter = _line_edit.text
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
	assert(_line_edit.gui_input.connect(_line_edit_gui_input) == OK)

func _popup_panel_hide() -> void:
	if _line_edit.text_changed.is_connected(_on_text_changed):
		_line_edit.text_changed.disconnect(_on_text_changed)
 
func _popup_panel_focus_entered() -> void:
	grab_focus()

func _popup_panel_index_pressed(index: int) -> void:
	var le_text = _popup_panel.get_item_text(index)
	_line_edit.text = le_text
	_filter = _line_edit.text
	selected = _items.find(_line_edit.text)

func _line_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_update_popup_view()
			if not _line_edit.text_changed.is_connected(_on_text_changed):
				assert(_line_edit.text_changed.connect(_on_text_changed) == OK)

func _on_text_changed(filter: String) -> void:
	_filter = filter
	_update_popup_view(_filter)

func _update_popup_view(filter = _filter) -> void:
	_update_items_view(filter)
	var rect = get_global_rect()
	var position =  Vector2(rect.position.x, rect.position.y + rect.size.y)
	if Engine.is_editor_hint():
		print(get_parent().get_viewport_rect())
		position = Vector2(rect.position.x, rect.position.y)
		print("rect_position -> ", rect_position)
		print("get_global_rect()", get_global_rect())
		print("get_viewport_rect() -> ", get_viewport_rect())
		print("get_global_transform() -> ", get_global_transform())
		print("get_global_transform_with_canvas() -> ", get_global_transform_with_canvas())
		print("get_viewport().get_visible_rect() -> ",  get_viewport().get_visible_rect())
		
	var size = Vector2(rect.size.x, _popup_calc_height())
	_popup_panel.popup(Rect2(position, size))
	_line_edit.grab_focus()

func _popup_calc_height() -> int:
	var child_count = _popup_panel_vbox.get_child_count() 
	if child_count > 0:
		var single_height: int = _line_edit.rect_size.y
		if child_count >= popup_maxheight_count:
			return popup_maxheight_count * single_height
		else:
			return child_count * single_height
	return 0

func _update_items_view(filter = "") -> void:
	for child in _popup_panel_vbox.get_children():
		_popup_panel_vbox.remove_child(child)
		child.queue_free()
	for index in range(_items.size()):
		if filter.length() <= 0:
			_popup_panel_vbox.add_child(_init_check_box(index))
		else:
			if filter in _items[index]:
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
		_line_edit.text = _filter
		emit_signal("selection_changed")
	_popup_panel.hide()
