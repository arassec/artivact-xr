class_name TextWidget

extends Widget

var heading: TranslatableString
var content: TranslatableString


func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("heading"):
			heading = TranslatableString.new(data["heading"])
		if data.has("content"):
			content = TranslatableString.new(data["content"])
