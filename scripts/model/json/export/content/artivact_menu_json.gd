class_name ArtivactMenuJson

extends TranslatableRestrictedString


var menuEntries: Array[ArtivactMenuJson] = []
var targetPageId: String = ""
var exportTitle: TranslatableString
var exportDescription: TranslatableString

func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("menuEntries"):
			for menuEntryJson in data["menuEntries"]:
				menuEntries.append(ArtivactMenuJson.new(menuEntryJson))
		if data.has("targetPageId"):
			targetPageId = data["targetPageId"]
		if data.has("exportTitle"):
			exportTitle = TranslatableString.new(data["exportTitle"])
		if data.has("exportDescription"):
			exportDescription = TranslatableString.new(data["exportDescription"])
