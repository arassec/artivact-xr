class_name Widget

extends Object

enum WidgetType {
	PAGE_TITLE,
	TEXT,
	ITEM_SEARCH,
	INFO_BOX,
	AVATAR,
	SPACE,
	IMAGE_TEXT
}

var id: String = ""
var type: WidgetType

func _init(data: Dictionary):
	if data:
		if data.has("id"):
			id = data["id"]
		if data.has("type"):
			type = WidgetType.get(data["type"])


func label() -> String:
	return WidgetType.keys()[type]
