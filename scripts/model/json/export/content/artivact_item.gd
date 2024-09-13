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
		if data.has("id"):
			id = data["id"]
		if data.has("title"):
			title = TranslatableString.new(data["title"])
		if data.has("description"):
			description = TranslatableString.new(data["description"])
		if data.has("properties"):
			for propertyKey in data["properties"].keys():
				properties[propertyKey] = TranslatableString.new(data["properties"][propertyKey])
		if data.has("tags"):
			for tag in data["tags"]:
				tags.append(Tag.new(tag))
		if data.has("mediaContent"):
			var mediaContent = data["mediaContent"]
			if mediaContent.has("images"):
				for image in mediaContent["images"]:
					images.append(image)
			if mediaContent.has("models"):
				for model in mediaContent["models"]:
					models.append(model)
