class_name AvatarWidget

extends Widget


var avatarImage: String
var avatarSubtext: TranslatableString


func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("avatarImage") and data["avatarImage"] != null:
			avatarImage = data["avatarImage"]
		if data.has("avatarSubtext") and data["avatarSubtext"] != null:
			avatarSubtext = TranslatableString.new(data["avatarSubtext"])
