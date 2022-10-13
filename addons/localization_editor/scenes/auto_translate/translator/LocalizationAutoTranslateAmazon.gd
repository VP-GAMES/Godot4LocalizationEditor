# List of locales supported by Amazon translator for LocalizationEditor : MIT License
# @author Vladimir Petrenko
# @see https://aws.amazon.com/translate/
extends Object
class_name LocalizationAutoTranslateAmazon

static func locales() -> Array: #[LocalizationLocaleSingle]:
	return [
		LocalizationLocaleSingle.new("BG", "Bulgarian"),
		LocalizationLocaleSingle.new("CS", "Czech"),
		LocalizationLocaleSingle.new("DA", "Danish"),
		LocalizationLocaleSingle.new("DE", "German"),
		LocalizationLocaleSingle.new("EL", "Greek"),
		LocalizationLocaleSingle.new("EN-GB", "English (British)"),
		LocalizationLocaleSingle.new("EN-US", "English (American)"),
		LocalizationLocaleSingle.new("ES", "Spanish"),
		LocalizationLocaleSingle.new("ET", "Estonian"),
		LocalizationLocaleSingle.new("FI", "Finnish"),
		LocalizationLocaleSingle.new("FR", "French"),
		LocalizationLocaleSingle.new("HU", "Hungarian"),
		LocalizationLocaleSingle.new("ID", "Indonesian"),
		LocalizationLocaleSingle.new("IT", "Italian"),
		LocalizationLocaleSingle.new("JA", "Japanese"),
		LocalizationLocaleSingle.new("LT", "Lithuanian"),
		LocalizationLocaleSingle.new("LV", "Latvian"),
		LocalizationLocaleSingle.new("NL", "Dutch"),
		LocalizationLocaleSingle.new("PL", "Polish"),
		LocalizationLocaleSingle.new("PT-BR", "Portuguese (Brazilian)"),
		LocalizationLocaleSingle.new("PT-PT", "Portuguese (all Portuguese varieties excluding Brazilian Portuguese)"),
		LocalizationLocaleSingle.new("RO", "Romanian"),
		LocalizationLocaleSingle.new("RU", "Russian"),
		LocalizationLocaleSingle.new("SK", "Slovak"),
		LocalizationLocaleSingle.new("SL", "Slovenian"),
		LocalizationLocaleSingle.new("SV", "Swedish"),
		LocalizationLocaleSingle.new("TR", "Turkish"),
		LocalizationLocaleSingle.new("UK", "Ukrainian"),
		LocalizationLocaleSingle.new("ZH", "Chinese (simplified)")
	]

static func label_by_code(code: String) -> String:
	for locale in locales():
		if locale.code == code:
			return locale.code + " " + locale.name
	return ""
