# List of locales supported by Yandex translator for LocalizationEditor : MIT License
# @author Vladimir Petrenko
# @see https://www.deepl.com/docs-api/translate-text/translate-text/
extends Object
class_name LocalizationAutoTranslateYandex

static func locales() -> Array: #[LocalizationLocaleSingle]:
	return [
		LocalizationLocaleSingle.new("Az", "Azerbaijani"),
		LocalizationLocaleSingle.new("Al", "Albanian"),
	]

static func label_by_code(code: String) -> String:
	for locale in locales():
		if locale.code == code:
			return locale.code + " " + locale.name
	return ""
