extends UnitTest
class_name TestLocalizationLocalesList

func _get_class_name() -> String:
	return "TestLocalizationLocalesList"

func _test_create_localization_locales_list() -> void:
	var locales_list: = LocalizationLocalesList.Locales
	assertNotNull(locales_list)
	assertTrue(!locales_list.is_empty())

func _test_create_localization_locales_list_by_code() -> void:
	var localizationLocaleSingle: LocalizationLocaleSingle = LocalizationLocalesList.by_code("en")
	assertEquals(localizationLocaleSingle.code, "en")
	assertEquals(localizationLocaleSingle.name, "English")

func _test_create_localization_locales_list_label_by_code() -> void:
	var label: String = LocalizationLocalesList.label_by_code("en")
	assertEquals(label, "en English")

func _test_create_localization_locales_list_by_label_by_code() -> void:
	for code in LocalizationLocalesList.Locales.keys():
		var label: String = LocalizationLocalesList.label_by_code(code)
		assertEquals(label, code + " " + LocalizationLocalesList.Locales[code])

func _test_create_localization_locales_list_has_code() -> void:
	assertTrue(LocalizationLocalesList.has_code("en"))

