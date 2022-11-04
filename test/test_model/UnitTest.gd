extends Node
class_name UnitTest

signal method_done
signal assert_done
signal assert_fail
signal assert_success

@onready var _buttonFail: Button
@onready var _buttonSuccess: Button
@onready var _class: CheckBox
@onready var _method: CheckBox
@onready var _assert: CheckBox

var _texture_fail = preload("res://test/test_model/icons/Fail.svg")
var _texture_success = preload("res://test/test_model/icons/Success.svg")

var _tree: Tree
var _root: TreeItem
var _class_item: TreeItem
var _method_item: TreeItem

var _actual_test_class: String = ""
var _actual_test_class_fail: bool = false
var _actual_test_method: String = ""
var _actual_test_method_fail: bool = false

func under_test() -> void:
	_init_tree()
	_actual_test_class = _get_class_name()
	var methods: Array[Dictionary] = calc_methods()
	_class_item = _tree.create_item(_root)
	_class_item.set_text(0, _actual_test_class)
	_actual_test_class_fail = false
	for method in methods:
		_actual_test_method_fail = false
		_actual_test_method = method.name
		_method_item = _tree.create_item(_class_item)
		_method_item.set_text(0, str(_actual_test_method, "()"))
		call(method.name)
		if !_method.button_pressed:
			_class_item.remove_child(_method_item)
		if _actual_test_method_fail:
			_actual_test_class_fail = true
			_method_item.set_icon(0, _texture_fail)
			if !_buttonFail.button_pressed:
				_class_item.remove_child(_method_item)
		else:
			_method_item.set_icon(0, _texture_success)
			if !_buttonSuccess.button_pressed:
				_class_item.remove_child(_method_item)
		emit_signal("method_done")
	if !_class.button_pressed:
		_root.remove_child(_class_item)
	if _actual_test_class_fail:
		_class_item.set_icon(0, _texture_fail)
		if !_buttonFail.button_pressed:
			_root.remove_child(_class_item)
	else:
		_class_item.set_icon(0, _texture_success)
		if !_buttonSuccess.button_pressed:
			_root.remove_child(_class_item)

func calc_methods() -> Array[Dictionary]:
	var attached_script = get_script()
	var methods: Array[Dictionary] = attached_script.get_script_method_list()
	return methods.filter(func(method): return method.name.begins_with("test_") or method.name.begins_with("_test_"))

func calc_methods_count() -> int:
	return calc_methods().size()

func _init_tree() -> void:
	_tree = owner.get_node("Tree")
	_buttonFail = owner.get_node("MarginContainer/HBoxContainer/ButtonFail")
	_buttonSuccess = owner.get_node("MarginContainer/HBoxContainer/ButtonSuccess")
	_class = owner.get_node("MarginContainer/HBoxContainer/Class")
	_method = owner.get_node("MarginContainer/HBoxContainer/Method")
	_assert = owner.get_node("MarginContainer/HBoxContainer/Assert")
	_root = _tree.get_root()
	if _root == null:
		_root = _tree.create_item()
		_tree.hide_root = true

func _get_class_name() -> String:
	return get_class()

func _create_item(test_message: String, test_success: bool = false) -> void:
	if test_success != true:
		emit_signal("assert_fail")
		_actual_test_method_fail = true
	else:
		emit_signal("assert_success")
	if _assert.button_pressed:
		if _buttonFail.button_pressed and !test_success or _buttonSuccess.button_pressed and test_success:
			var test_text = str(_actual_test_method, "() : ", test_message)
			var test_method = _tree.create_item(_method_item)
			var test_icon = _texture_fail
			if test_success == true:
				test_icon = _texture_success
			test_method.set_icon(0, test_icon)
			test_method.set_text(0, test_text)

func fail(test_message: String = "") -> void:
	_create_item(str(test_message, ".fail()"))
	emit_signal("assert_done")

func success(test_message: String = "") -> void:
	_create_item(str(test_message, ".cuccess()"), true)
	emit_signal("assert_done")

func assertNull(object: Variant, test_message: String = "") -> void:
	var test_value = object == null
	if test_message.is_empty():
		if test_value:
			test_message = "null."
		else:
			test_message = "Not null."
	_create_item(str(test_message, ".assertNull()"), test_value)
	emit_signal("assert_done")

func assertNotNull(object: Variant, test_message: String = "") -> void:
	_create_item(str(test_message, ".assertNotNull()"), object != null)
	emit_signal("assert_done")

func assertFalse(object: Variant, test_message: String = "") -> void:
	_create_item(str(test_message, ".assertFalse()"), object == false)
	emit_signal("assert_done")

func assertTrue(object: Variant, test_message: String = "") -> void:
	_create_item(str(test_message, ".assertTrue()"), object == true)
	emit_signal("assert_done")

func assertEquals(expected: Variant, actual: Variant, test_message: String = "") -> void:
	_create_item(str(test_message, ".assertEquals()"), expected == actual)
	emit_signal("assert_done")

func assertNotEquals(expected: Variant, actual: Variant, test_message: String = "") -> void:
	_create_item(str(test_message, ".assertNotEquals()"), expected != actual)
	emit_signal("assert_done")
