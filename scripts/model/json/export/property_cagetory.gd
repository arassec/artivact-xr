class_name PropertyCategory

extends TranslatableRestrictedString

var properties: Array[Property] = []


func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("properties") and data["properties"] is Array:
			for property in data["properties"]:
				properties.append(Property.new(property))
