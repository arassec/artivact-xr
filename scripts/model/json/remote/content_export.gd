class_name ContentExport

extends Object

var id: String = ""
var title: TranslatableString
var description: TranslatableString
var lastModified: int = -1
var size: int = -1


func _init(data: Dictionary):
	if data:
		if data.has("id"):
			id = data["id"]
		if data.has("title"):
			title = TranslatableString.new(data["title"])
		if data.has("description"):
			description =  TranslatableString.new(data["description"])
		if data.has("lastModified"):
			lastModified = data["lastModified"]
		if data.has("size"):
			size = data["size"]
