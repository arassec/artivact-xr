extends Node

var locale: String

func _init():
	locale = OS.get_locale_language()
	print("Locale is set to %s" % locale)
	

func translate(translatableObject: Dictionary) -> String:
	if translatableObject:
		if translatableObject.has("translations"):
			if translatableObject.translations.has(locale):
				return translatableObject.translations[locale]
	
	if translatableObject:
		if translatableObject.has("value"):
			return translatableObject.value
			
	return ""
