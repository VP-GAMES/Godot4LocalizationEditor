extends UnitTest
class_name TestLocalizationLocalesList

func _get_class_name() -> String:
	return "TestLocalizationLocalesList"

func _test_create_localization_locales_list() -> void:
	var locales_list: = LocalizationLocalesList.LOCALES
	assertNotNull(locales_list)
	assertTrue(!locales_list.is_empty())

func _test_create_localization_locales_list_label_by_code() -> void:
	var label: String = LocalizationLocalesList.label_by_code("en")
	assertEquals(label, "en English")

func _test_create_localization_locales_list_has_code() -> void:
	assertTrue(LocalizationLocalesList.has_code("en"))

