class_name Tag

extends TranslatableRestrictedString

var url: String = ""
var defaultTag: bool = false


func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("url") and data["url"] != null:
			url = data["url"]
		if data.has("defaultTag") and data["defaultTag"] != null:
			defaultTag = data["defaultTag"]
