class_name ArtivactContentJson

extends Object

var schemaVersion: int = -1
var title: TranslatableString
var description: TranslatableString
var content: TranslatableString
var exchangeType: String = ""
var sourceIds: Array[String] = []

func _init(data: Dictionary):
	if data:
		if data.has("schemaVersion") and data["schemaVersion"] != null:
			schemaVersion = data["schemaVersion"]
		if data.has("title") and data["title"] != null:
			title = TranslatableString.new(data["title"])
		if data.has("description") and data["description"] != null:
			description =  TranslatableString.new(data["description"])
		if data.has("content") and data["content"] != null:
			content =  TranslatableString.new(data["content"])
		if data.has("contentSource") and data["contentSource"] != null:
			exchangeType = data.contentSource
		if data.has("sourceIds") and data["sourceIds"] is Array:
			for sourceId in data["sourceIds"]:
				sourceIds.append(sourceId)
