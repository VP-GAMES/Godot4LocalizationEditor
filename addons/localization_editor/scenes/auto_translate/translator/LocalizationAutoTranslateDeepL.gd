# List of locales supported by DeepL translator for LocalizationEditor : MIT License
# @author Vladimir Petrenko
# @see https://www.deepl.com/docs-api/translate-text/translate-text/
class_name LocalizationAutoTranslateDeepL

const LOCALES = {
	"BG": "Bulgarian",
	"CS": "Czech",
	"DA": "Danish",
	"DE": "German",
	"EL": "Greek",
	"EN-GB": "English (British)",
	"EN-US": "English (American)",
	"ES": "Spanish",
	"ET": "Estonian",
	"FI": "Finnish",
	"FR": "French",
	"HU": "Hungarian",
	"ID": "Indonesian",
	"IT": "Italian",
	"JA": "Japanese",
	"LT": "Lithuanian",
	"LV": "Latvian",
	"NL": "Dutch",
	"PL": "Polish",
	"PT-BR": "Portuguese (Brazilian)",
	"PT-PT": "Portuguese (all Portuguese varieties excluding Brazilian Portuguese)",
	"RO": "Romanian",
	"RU": "Russian",
	"SK": "Slovak",
	"SL": "Slovenian",
	"SV": "Swedish",
	"TR": "Turkish",
	"UK": "Ukrainian",
	"ZH": "Chinese (simplified)"
}

static func label_by_code(code: String) -> String:
	if LOCALES.has(code.to_lower()):
		return code + " " + LOCALES[code.to_lower()]
	return ""
