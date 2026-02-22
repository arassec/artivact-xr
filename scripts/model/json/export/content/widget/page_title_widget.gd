class_name PageTitleWidget

extends Widget

var title: TranslatableString
var backgroundImage: String


func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("title") and data["title"] != null:
			title = TranslatableString.new(data["title"])
		if data.has("backgroundImage") and data["backgroundImage"] != null:
			backgroundImage = data["backgroundImage"]
