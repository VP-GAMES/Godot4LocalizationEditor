# UI Extension Filter Dropdown : MIT License
# @author Vladimir Petrenko
@tool
extends VBoxContainer
class_name Dropdown

signal selection_changed(item: DropdownItem)

var _disabled: bool = false
var _selected = -1
var _group = ButtonGroup.new()
var _items: Array[DropdownItem] = []

@export var ignore_case: bool = true
@export var popup_maxheight_count: int = 5
@onready var _icon: TextureRect = $HBox/Icon
@onready var _selector: Button = $HBox/Selector
@onready var _clear: Button= $HBox/Clear
@onready var _popup_panel: PopupPanel= $PopupPanel
@onready var _filter: LineEdit= $PopupPanel/VBoxPanel/Filter
@onready var _popup_panel_vbox: VBoxContainer= $PopupPanel/VBoxPanel/Scroll/ScrollVBox/VBox

func set_disabled(value: bool) -> void:
	_disabled = value
	_selector.disabled = _disabled
	_clear.disabled = _disabled

func is_disabled() -> bool:
	return _disabled

func items() -> Array:
	return _items

func add_item_as_string(value: String, tooltip: String = "") -> void:
	add_item(DropdownItem.new(value, value, tooltip))

func add_item(item: DropdownItem) -> void:
	_items.append(item)

func clear() -> void:
	for item in _items:
		item.free()
	_items = []

func erase_item_by_string(value: String) -> void:
	erase_item(DropdownItem.new(value, value))

func erase_item(item: DropdownItem) -> void:
	_items.erase(item)
	item.free()

func set_selected_item(item: DropdownItem) -> void:
	_on_selection_changed(_items.find(item))

func set_selected_index(index: int) -> void:
	_on_selection_changed(index)

func set_selected_by_value(value) -> void:
	for item in _items:
		if item.value == value:
			set_selected_item(item)
			return

func get_selected_index() -> int:
	return _selected

func get_selected_item():
	if _selected >=0:
		return _items[_selected]
	return null

func get_selected_value():
	if _selected >=0:
		return _items[_selected].value
	return null

func _ready() -> void:
	_group.resource_local_to_scene = false
	_update_view()
	_init_connections()

func _update_view() -> void:
	_update_view_icon()
	_update_view_button()

func _update_view_icon() -> void:
	if _selected >= 0 and _items[_selected].icon != null:
		_icon.show()
	else:
		_icon.hide()

func _update_view_button() -> void:
	_clear.visible = _selected >= 0

func _init_connections() -> void:
	_selector.pressed.connect(_update_popup_view)
	_clear.pressed.connect(_clear_pressed)
	_filter.text_changed.connect(_filter_changed)

func _update_popup_view() -> void:
	if _disabled:
		return
	_update_items_view()
	var rect = get_global_rect()
	var position =  Vector2(rect.position.x, rect.position.y + rect.size.y + 2)
	if Engine.is_editor_hint():
		position = get_viewport().canvas_transform * global_position + Vector2(get_viewport().position)
		position.y += size.y
	_popup_panel.position = position
	_popup_panel.popup()

func _update_items_view() -> void:
	for child in _popup_panel_vbox.get_children():
		_popup_panel_vbox.remove_child(child)
		child.queue_free()
	for index in range(_items.size()):
		if _filter.text.length() <= 0:
			_popup_panel_vbox.add_child(_init_check_box(index))
		else:
			var filter_text = _filter.text
			var item_text = _items[index].text
			if ignore_case:
				filter_text = filter_text.to_upper()
				item_text = item_text.to_upper()
			if filter_text in item_text:
				_popup_panel_vbox.add_child(_init_check_box(index))
	var rect = get_global_rect()
	var size = Vector2(rect.size.x, _popup_calc_height())
	_popup_panel.set_size(size)

func _popup_calc_height() -> int:
	var child_count = _popup_panel_vbox.get_child_count()
	if child_count > 0:
		var single_height: int = _popup_panel_vbox.get_child(0).size.y + 5
		if child_count >= popup_maxheight_count:
			return (popup_maxheight_count + 1) * single_height
		else:
			if Engine.is_editor_hint():
				return (child_count + 1) * single_height + single_height / 2 
			else:
				return (child_count + 1) * single_height
	return 0

func _init_check_box(index: int) -> CheckBox:
	var check_box = CheckBox.new()
	check_box.set_button_group(_group)
	check_box.text = _items[index].text
	check_box.tooltip_text = _items[index].tooltip
	if _items[index].icon != null:
		check_box.expand_icon = true
		check_box.icon = _items[index].icon
	if index == _selected:
		check_box.set_pressed(true)
	check_box.pressed.connect(_on_selection_changed.bind(index))
	return check_box

func _on_selection_changed(index: int) -> void:
	if index < 0:
		_selected = -1
		_selector.text = ""
	else:
		_selected = index
		_selector.text = _items[_selected].text
		_selector.tooltip_text = _items[_selected].tooltip
		if _items[_selected].icon != null:
			_icon.texture = _items[_selected].icon
		emit_signal("selection_changed", _items[_selected])
	_popup_panel.hide()
	_update_view()

func _clear_pressed() -> void:
	set_selected_index(-1)

func _filter_changed(_text: String) -> void:
	_update_items_view()
