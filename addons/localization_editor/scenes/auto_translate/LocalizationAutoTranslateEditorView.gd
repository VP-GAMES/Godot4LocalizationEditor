# Auto Translate view for LocalizationEditor : MIT License
# @author Vladimir Petrenko
@tool
extends VBoxContainer

@onready var _translators_ui = $Translators

func set_data(data: LocalizationData) -> void:
	_translators_ui.set_data(data)
