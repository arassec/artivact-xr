class_name Tag

extends TranslatableRestrictedString

var url: String = ""
var defaultTag: bool = false


func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("url"):
			url = data["url"]
		if data.has("defaultTag"):
			defaultTag = data["defaultTag"]
