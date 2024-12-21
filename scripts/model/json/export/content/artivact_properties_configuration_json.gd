class_name ArtivactPropertiesConfigurationJson

extends Object


var propertyCategories: Array[PropertyCategory] = []


func _init(data: Dictionary):
	if data:
		if data.has("propertyCategories"):
			for propertyCategory in data["propertyCategories"]:
				propertyCategories.append(PropertyCategory.new(propertyCategory))
