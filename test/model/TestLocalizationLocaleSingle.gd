extends UnitTest
class_name TestLocalizationLocaleSingle

func _get_class_name() -> String:
	return "TestLocalizationLocaleSingle"

func _test_create_localization_locale_single() -> void:
	var localizationLocaleSingle: LocalizationLocaleSingle = LocalizationLocaleSingle.new("code", "name")
	assertNotNull(localizationLocaleSingle)

func _test_create_localization_locale_single_code() -> void:
	var localizationLocaleSingle: LocalizationLocaleSingle = LocalizationLocaleSingle.new("code", "name")
	assertEquals(localizationLocaleSingle.code, "code")

func _test_create_localization_locale_single_name() -> void:
	var localizationLocaleSingle: LocalizationLocaleSingle = LocalizationLocaleSingle.new("code", "name")
	assertEquals(localizationLocaleSingle.name, "name")
