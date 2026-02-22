class_name ArtivactItem

extends Object


var id: String
var title: TranslatableString
var description: TranslatableString
var properties: Dictionary = {}
var tags: Array[Tag] = []
var images: Array[String] = []
var models: Array[String] = []


func _init(data: Dictionary):
	if data != null:
		if data.has("id") and data["id"] != null:
			id = data["id"]
		if data.has("title") and data["title"] != null:
			title = TranslatableString.new(data["title"])
		if data.has("description") and data["description"] != null:
			description = TranslatableString.new(data["description"])
		if data.has("properties") and data["properties"] is Array:
			for propertyKey in data["properties"].keys():
				properties[propertyKey] = TranslatableString.new(data["properties"][propertyKey])
		if data.has("tags") and data["tags"] is Array:
			for tag in data["tags"]:
				tags.append(Tag.new(tag))
		if data.has("mediaContent") and data["mediaContent"] != null:
			var mediaContent = data["mediaContent"]
			if mediaContent.has("images") and mediaContent["images"] is Array:
				for image in mediaContent["images"]:
					images.append(image)
			if mediaContent.has("models") and mediaContent["models"] is Array:
				for model in mediaContent["models"]:
					models.append(model)
