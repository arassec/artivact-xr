class_name ArtivactMenuJson

extends TranslatableRestrictedString


var menuEntries: Array[ArtivactMenuJson] = []
var targetPageId: String = ""

func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("menuEntries") and data["menuEntries"] is Array:
			for menuEntryJson in data["menuEntries"]:
				menuEntries.append(ArtivactMenuJson.new(menuEntryJson))
		if data.has("targetPageId") and data["targetPageId"] != null:
			targetPageId = data["targetPageId"]
