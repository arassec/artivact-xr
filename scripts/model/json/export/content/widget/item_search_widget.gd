class_name ItemSearchWidget

extends Widget

var heading: TranslatableString
var content: TranslatableString

func _init(data: Dictionary):
	super._init(data)
	if data.has("heading"):
		heading = TranslatableString.new(data["heading"])
	if data.has("content"):
		content = TranslatableString.new(data["content"])
	# The other properties are not used at the moment...
