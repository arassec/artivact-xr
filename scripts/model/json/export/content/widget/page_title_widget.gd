class_name PageTitleWidget

extends Widget

var title: TranslatableString
var backgroundImage: String


func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("title"):
			title = TranslatableString.new(data["title"])
		if data.has("backgroundImage"):
			backgroundImage = data["backgroundImage"]
