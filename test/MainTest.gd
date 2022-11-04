extends VBoxContainer

@onready var _restart: Button = $MarginContainer/HBoxContainer/Restart
@onready var _result: Label = $MarginContainer/HBoxContainer/Result
@onready var _progressBar: ProgressBar = $ProgressBar
@onready var _tree: Tree = $Tree
@onready var _testList: Node = $TestList

var _progress_value: int = 0
var _assert_count:int = 0
var _assert_fail_count:int = 0
var _assert_success_count:int = 0

func _ready():
	_restart.pressed.connect(_on_restart_pressed)
	_on_restart_pressed()

func _process(_delta):
	_progressBar.value = _progress_value

func _on_restart_pressed() -> void:
	_tree.clear()
	var childrens = _testList.get_children()
	var count = 0
	_progress_value = 0
	_assert_count = 0
	_assert_fail_count = 0
	_assert_success_count = 0
	for testCase in childrens:
		count += testCase.calc_methods_count()
	_progressBar.max_value = count
	for testCase in childrens:
		if not testCase.method_done.is_connected(_on_method_done):
			testCase.method_done.connect(_on_method_done)
		if not testCase.assert_done.is_connected(_on_assert_done):
			testCase.assert_done.connect(_on_assert_done)
		if not testCase.assert_fail.is_connected(_on_assert_fail):
			testCase.assert_fail.connect(_on_assert_fail)
		if not testCase.assert_success.is_connected(_on_assert_success):
			testCase.assert_success.connect(_on_assert_success)
		testCase.under_test()

func _on_method_done() -> void:
	_progress_value = _progress_value + 1

func _on_assert_done() -> void:
	_assert_count += 1
	_update_result_text()

func _on_assert_fail() -> void:
	_assert_fail_count += 1
	_update_result_text()

func _on_assert_success() -> void:
	_assert_success_count += 1
	_update_result_text()

func _update_result_text() -> void:
	_result.text = str("(Failures: ", _assert_fail_count, ", Success: ", _assert_success_count, ", Asserts: ", _assert_count, ")")
