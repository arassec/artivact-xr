class_name Property

extends TranslatableRestrictedString

var valueRange: Array[TranslatableRestrictedString] = []


func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("valueRange"):
			for valueRangeEntry in data["valueRange"]:
				valueRange.append(TranslatableRestrictedString.new(valueRangeEntry))
