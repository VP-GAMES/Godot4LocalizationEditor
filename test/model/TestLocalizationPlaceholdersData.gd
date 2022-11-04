extends UnitTest
class_name TestLocalizationPlaceholdersData

func _get_class_name() -> String:
	return "LocalizationPlaceholdersData"

func _test_create_localization_placeholders_data() -> void:
	var localizationPlaceholdersData: LocalizationPlaceholdersData = LocalizationPlaceholdersData.new()
	assertNotNull(localizationPlaceholdersData)

func _test_create_localization_placeholders_data_null() -> void:
	var localizationPlaceholdersData: LocalizationPlaceholdersData = LocalizationPlaceholdersData.new()
	assertNotNull(localizationPlaceholdersData.placeholders)
	assertTrue(localizationPlaceholdersData.placeholders.is_empty())
