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
var navigationTitle: TranslatableString


func _init(data: Dictionary):
	if data:
		if data.has("id"):
			id = data["id"]
		if data.has("type"):
			type = WidgetType.get(data["type"])
		if data.has("navigationTitle"):
			navigationTitle = TranslatableString.new(data["navigationTitle"])


func label() -> String:
	if navigationTitle != null && navigationTitle.translate() != null && navigationTitle.translate() != "":
		return navigationTitle.translate()
	else:
		return tr(WidgetType.keys()[type])
