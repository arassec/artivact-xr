class_name ArtivactPropertiesConfigurationJson

extends Object


var propertyCategories: Array[PropertyCategory] = []


func _init(data: Dictionary):
	if data:
		if data.has("categories"):
			for propertyCategory in data["categories"]:
				propertyCategories.append(PropertyCategory.new(propertyCategory))
