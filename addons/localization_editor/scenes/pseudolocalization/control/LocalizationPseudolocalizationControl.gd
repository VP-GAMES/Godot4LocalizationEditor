# LocalizationEditor PseudolocalizationControl: MIT License
# @author Vladimir Petrenko
@tool
extends VBoxContainer

const _pseudolocalization_control: String = "internationalization/pseudolocalization/use_pseudolocalization_control"

@onready var _pseudolocalization_ui: CheckBox = $HBox/Panel/PseudolocalizationControl

func _ready():
	if ProjectSettings.has_setting(_pseudolocalization_control):
		_pseudolocalization_ui.button_pressed = ProjectSettings.get_setting(_pseudolocalization_control)
	_pseudolocalization_ui.toggled.connect(_on_pseudolocalization_toggled)

func _on_pseudolocalization_toggled(button_pressed: bool) -> void:
	ProjectSettings.set_setting(_pseudolocalization_control, button_pressed)
	ProjectSettings.save()
