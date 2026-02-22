class_name InfoBoxWidget

extends Widget


enum BoxType {
	INFO,
	WARN,
	ALERT
}

var heading: TranslatableString
var content: TranslatableString
var boxType: BoxType


func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("heading") and data["heading"] != null:
			heading = TranslatableString.new(data["heading"])
		if data.has("content") and data["content"] != null:
			content = TranslatableString.new(data["content"])
		if data.has("boxType") and data["boxType"] != null:
			boxType = BoxType.get(data["boxType"])
