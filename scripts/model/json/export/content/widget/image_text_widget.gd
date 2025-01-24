class_name ImageTextWidget

extends Widget


var image: String
var text: TranslatableString


func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("image"):
			image = data["image"]
		if data.has("text"):
			text = TranslatableString.new(data["text"])
