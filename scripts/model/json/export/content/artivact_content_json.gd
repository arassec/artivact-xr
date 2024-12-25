class_name ArtivactContentJson

extends Object

var schemaVersion: int = -1
var title: TranslatableString
var description: TranslatableString
var exchangeType: String = ""
var sourceId: String = ""


func _init(data: Dictionary):
	if data:
		if data.has("schemaVersion"):
			schemaVersion = data["schemaVersion"]
		if data.has("title"):
			title = TranslatableString.new(data["title"])
		if data.has("description"):
			description =  TranslatableString.new(data["description"])
		if data.has("contentSource"):
			exchangeType = data.contentSource
		if data.has("sourceId"):
			sourceId = data.sourceId
