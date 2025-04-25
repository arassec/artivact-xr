class_name ImageGalleryWidget

extends Widget


var heading: TranslatableString
var content: TranslatableString
var images: Array[String] = []


func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("heading"):
			heading = TranslatableString.new(data["heading"])
		if data.has("content"):
			content = TranslatableString.new(data["content"])
		if data.has("images"):
			for image in data["images"]:
				images.append(String(image))
