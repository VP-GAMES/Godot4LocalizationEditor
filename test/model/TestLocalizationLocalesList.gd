extends UnitTest
class_name TestLocalizationLocalesList

func _get_class_name() -> String:
	return "TestLocalizationLocalesList"

func _test_create_localization_locales_list() -> void:
	var locales_list: Array[LocalizationLocaleSingle] = LocalizationLocalesList.locales()
	assertNotNull(locales_list)
	assertTrue(!locales_list.is_empty())

func _test_create_localization_locales_list_by_code() -> void:
	var localizationLocaleSingle: LocalizationLocaleSingle = LocalizationLocalesList.by_code("en")
	assertEquals(localizationLocaleSingle.code, "en")
	assertEquals(localizationLocaleSingle.name, "English")

func _test_create_localization_locales_list_by_code_list() -> void:
	var locales_list: Array[LocalizationLocaleSingle] = LocalizationLocalesList.locales()
	for locale in locales_list:
		var localizationLocaleSingle: LocalizationLocaleSingle = LocalizationLocalesList.by_code(locale.code)
		assertEquals(localizationLocaleSingle.code, locale.code)
		assertEquals(localizationLocaleSingle.name, locale.name)

func _test_create_localization_locales_list_label_by_code() -> void:
	var label: String = LocalizationLocalesList.label_by_code("en")
	assertEquals(label, "en English")

func _test_create_localization_locales_list_by_label_by_code() -> void:
	var locales_list: Array[LocalizationLocaleSingle] = LocalizationLocalesList.locales()
	for locale in locales_list:
		var label: String = LocalizationLocalesList.label_by_code(locale.code)
		assertEquals(label, locale.code + " " + locale.name)

func _test_create_localization_locales_list_has_code() -> void:
	assertTrue(LocalizationLocalesList.has_code("en"))

func _test_create_localization_locales_list_has_code_list() -> void:
	var locales_list: Array[LocalizationLocaleSingle] = LocalizationLocalesList.locales()
	for locale in locales_list:
		assertTrue(LocalizationLocalesList.has_code(locale.code))
