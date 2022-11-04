extends UnitTest
class_name TestLocalizationData

func _get_class_name() -> String:
	return "TestLocalizationData"

func _test_create_test_localization_data() -> void:
	var localizationData: LocalizationData = LocalizationData.new()
	assertNotNull(localizationData)
	assertNotNull(localizationData.data)
	assertTrue(localizationData.data.locales.is_empty())
	assertTrue(localizationData.data.keys.is_empty())
	assertTrue(localizationData.data_filter.is_empty())

# ***** LOCALES *****
func _test_locales_empty() -> void:
	var localizationData: LocalizationData = LocalizationData.new()
	assertTrue(localizationData.locales().is_empty())

func _test_check_locale() -> void:
	var localizationData: LocalizationData = LocalizationData.new()
	assertNull(localizationData.find_locale("en"))
	localizationData.check_locale("en")
	localizationData.add_locale("en")
	assertNotNull(localizationData.find_locale("en"))

func _test_find_locale() -> void:
	var localizationData: LocalizationData = LocalizationData.new()
	assertNull(localizationData.find_locale("en"))
	localizationData.add_locale("en")
	assertEquals(localizationData.find_locale("en"), "en")

func _test_add_locale() -> void:
	var localizationData: LocalizationData = LocalizationData.new()
	assertNull(localizationData.find_locale("en"))
	localizationData.add_locale("en")
	assertNotNull(localizationData.find_locale("en"))

func _test_add_locale_with_keys() -> void:
	var localizationData: LocalizationData = LocalizationData.new()
	assertTrue(localizationData.keys().is_empty())
	localizationData.add_locale("en")
	localizationData.keys()
	assertFalse(localizationData.keys().is_empty())
