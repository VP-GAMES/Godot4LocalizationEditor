extends UnitTest
class_name TestLocalizationSave

func _get_class_name() -> String:
	return "TestLocalizationSave"

func _test_create_localization_save() -> void:
	var localizationSave: LocalizationSave = LocalizationSave.new()
	assertNotNull(localizationSave)

func _test_create_localization_save_data_null() -> void:
	var localizationSave: LocalizationSave = LocalizationSave.new()
	assertNotNull(localizationSave.locale)
	assertNotNull(localizationSave.placeholders)
	assertTrue(localizationSave.placeholders.is_empty())

func _test_create_localization_save_set_locale() -> void:
	var localizationSave: LocalizationSave = LocalizationSave.new()
	localizationSave.locale = "en"
	assertEquals(localizationSave.locale, "en")
