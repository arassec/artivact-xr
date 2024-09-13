class_name TranslatableRestrictedString

extends TranslatableString

var id: String = ""
var restrictions = []

func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("id"):
			id = data["id"]
		if data.has("restrictions"):
			restrictions = data["restrictions"]
