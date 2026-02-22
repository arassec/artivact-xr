class_name Property

extends TranslatableRestrictedString

var valueRange: Array[TranslatableRestrictedString] = []


func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("valueRange") and data["valueRange"] is Array:
			for valueRangeEntry in data["valueRange"]:
				valueRange.append(TranslatableRestrictedString.new(valueRangeEntry))
