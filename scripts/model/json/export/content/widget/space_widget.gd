class_name SpaceWidget

extends Widget

var size: int


func _init(data: Dictionary):
	super._init(data)
	if data:
		if data.has("size"):
			size = data["size"]
