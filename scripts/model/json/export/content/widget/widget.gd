class_name Widget

extends Object

enum WidgetType {
	UNSUPPORTED,
	PAGE_TITLE,
	TEXT,
	ITEM_SEARCH,
	INFO_BOX,
	AVATAR,
	IMAGE_GALLERY
}

var id: String = ""
var type: WidgetType
var navigationTitle: TranslatableString


func _init(data: Dictionary):
	if data:
		if data.has("id") and data["id"] != null:
			id = data["id"]
		if data.has("type") and data["type"] != null:
			type = WidgetType.get(data["type"], WidgetType.UNSUPPORTED)
		if data.has("navigationTitle") and data["navigationTitle"] != null:
			navigationTitle = TranslatableString.new(data["navigationTitle"])


func label() -> String:
	if navigationTitle != null && navigationTitle.translate() != null && navigationTitle.translate() != "":
		return navigationTitle.translate()
	else:
		return tr(WidgetType.keys()[type])
