class_name TranslatableString

extends Object


var value: String = ""
var translations: Dictionary = {}


func _init(data: Dictionary):
	if data:
		if data.has("value"):
			value = data["value"]
		if data.has("translations"):
			translations = data["translations"]


func translate():
	var locale = I18n.locale
	if translations.has(locale):
		var translatedValue = translations[locale]
		if translatedValue != "":
			return translatedValue
	return value
