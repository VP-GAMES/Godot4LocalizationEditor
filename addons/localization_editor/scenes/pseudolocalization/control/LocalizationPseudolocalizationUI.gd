# LocalizationEditor PseudolocalizationUI: MIT License
# @author Vladimir Petrenko
@tool
extends VBoxContainer

const _pseudolocalization: String = "internationalization/pseudolocalization/use_pseudolocalization"
const _accents: String = "internationalization/pseudolocalization/replace_with_accents"
const _double_vowels: String = "internationalization/pseudolocalization/double_vowels"
const _fake_bidi: String = "internationalization/pseudolocalization/fake_bidi"
const _override: String = "internationalization/pseudolocalization/override"
const _expansion_ratio: String = "internationalization/pseudolocalization/expansion_ratio"
const _prefix: String = "internationalization/pseudolocalization/prefix"
const _suffix: String = "internationalization/pseudolocalization/suffix"
const _skip_placeholders: String = "internationalization/pseudolocalization/skip_placeholders"

@onready var _pseudolocalization_ui: CheckBox = $HBoxPseudolocalization/Panel/Pseudolocalization
@onready var _accents_ui: CheckBox = $HBoxAccents/Panel/Accents
@onready var _double_vowels_ui: CheckBox = $HBoxDoubleVowels/Panel/DoubleVowels
@onready var _fake_bidi_ui: CheckBox = $HBoxFakeBidi/Panel/FakeBidi
@onready var _override_ui: CheckBox = $HBoxOverride/Panel/Override
@onready var _expansion_ratio_ui: LineEdit = $HBoxExpansionRatio/ExpansionRatio
@onready var _prefix_ui: LineEdit = $HBoxPrefix/ExpansionPrefix
@onready var _suffix_ui: LineEdit = $HBoxSuffix/ExpansionSuffix
@onready var _skip_placeholders_ui: CheckBox = $HBoxSkipPlaceholders/Panel/SkipPlaceholders

func _ready() -> void:
	_init_vars()
	_init_connections()

func _init_vars() -> void:
	_pseudolocalization_ui.button_pressed = TranslationServer.is_pseudolocalization_enabled()
	_accents_ui.button_pressed = ProjectSettings.get(_accents)
	_double_vowels_ui.button_pressed = ProjectSettings.get(_double_vowels)
	_fake_bidi_ui.button_pressed = ProjectSettings.get(_fake_bidi)
	_override_ui.button_pressed = ProjectSettings.get(_override)
	_expansion_ratio_ui.text = str(ProjectSettings.get(_expansion_ratio))
	_prefix_ui.text = ProjectSettings.get(_prefix)
	_suffix_ui.text = ProjectSettings.get(_suffix)
	_skip_placeholders_ui.button_pressed = ProjectSettings.get(_skip_placeholders)

func _init_connections() -> void:
	_pseudolocalization_ui.toggled.connect(_on_pseudolocalization_toggled)
	_accents_ui.toggled.connect(_on_accents_toggled)
	_double_vowels_ui.toggled.connect(_on_double_vowels_toggled)
	_fake_bidi_ui.toggled.connect(_on_fake_bidi_toggled)
	_override_ui.toggled.connect(_on_override_toggled)
	_expansion_ratio_ui.text_changed.connect(_on_expansion_ratio_text_changed)
	_prefix_ui.text_changed.connect(_on_prefix_text_changed)
	_suffix_ui.text_changed.connect(_on_suffix_text_changed)
	_skip_placeholders_ui.toggled.connect(_on_skip_placeholders_toggled)

func _on_pseudolocalization_toggled(button_pressed: bool) -> void:
	_change_project_setting(_pseudolocalization, button_pressed)
	TranslationServer.set_pseudolocalization_enabled(button_pressed)

func _on_accents_toggled(button_pressed: bool) -> void:
	_change_project_setting(_accents, button_pressed)

func _on_double_vowels_toggled(button_pressed: bool) -> void:
	_change_project_setting(_double_vowels, button_pressed)

func _on_fake_bidi_toggled(button_pressed: bool) -> void:
	_change_project_setting(_fake_bidi, button_pressed)

func _on_override_toggled(button_pressed: bool) -> void:
	_change_project_setting(_override, button_pressed)

func _on_expansion_ratio_text_changed() -> void:
	float()
	var ratio = (_expansion_ratio_ui.text).to_float()
	if ratio > 1:
		ratio = 1
		_expansion_ratio_ui.text = str(ratio)
	if ratio < 0:
		ratio = 0 
		_expansion_ratio_ui.text = str(ratio)
	_change_project_setting(_expansion_ratio, ratio)

func _on_prefix_text_changed() -> void:
	_change_project_setting(_prefix, _prefix_ui.text)

func _on_suffix_text_changed() -> void:
	_change_project_setting(_suffix, _suffix_ui.text)

func _on_skip_placeholders_toggled(button_pressed: bool) -> void:
	_change_project_setting(_skip_placeholders, button_pressed)

func _change_project_setting(property: String, value: Variant, reload: bool = true, save: bool = true) -> void:
	ProjectSettings.set(property, value)
	if reload:
		TranslationServer.reload_pseudolocalization()
	if save and Engine.is_editor_hint():
		ProjectSettings.save()
