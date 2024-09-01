class_name ArtivactContentJson

extends Object

var schemaVersion: int = -1
var title: TranslatableString
var description: TranslatableString
var menuId: String = ""
var propertyCategories: Array[PropertyCategory] = []
var tags: Array[Tag] = []


func _init(data: Dictionary):
	if data:
		if data.has("schemaVersion"):
			schemaVersion = data["schemaVersion"]
		if data.has("title"):
			title = TranslatableString.new(data["title"])
		if data.has("description"):
			description =  TranslatableString.new(data["description"])
		if data.has("menuId"):
			menuId = data.menuId
		if data.has("propertyCategories"):
			for propertyCategory in data["propertyCategories"]:
				propertyCategories.append(PropertyCategory.new(propertyCategory))
		if data.has("tags"):
			for tag in data["tags"]:
				tags.append(Tag.new(tag))
