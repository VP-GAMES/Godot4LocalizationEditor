extends CanvasLayer

const LocalizationPseudolocalizationWindow = preload("res://addons/localization_editor/scenes/pseudolocalization/ui/LocalizationPseudolocalizationWindow.tscn")

@onready var _view_ui: Button = $VBox/HBox/View

var _root
var _window = null

func _ready():
	_root = get_tree().get_root()
	_view_ui.pressed.connect(_on_view_ui_pressed)

func _on_view_ui_pressed() -> void:
	if _window == null:
		_create_dialogue()
	else:
		_window.move_to_foreground()

func _create_dialogue() -> void:
	var pseudolocalization_window: Window = LocalizationPseudolocalizationWindow.instantiate()
	_root.add_child(pseudolocalization_window)
	_window = pseudolocalization_window
	pseudolocalization_window.title = "Pseudolocalization"
	pseudolocalization_window.connect("close_requested", _on_window_hide)
	pseudolocalization_window.popup_centered(Vector2i(500, 315))

func _on_window_hide() -> void:
	_root.remove_child(_window)
	_window.queue_free()
	_window = null
