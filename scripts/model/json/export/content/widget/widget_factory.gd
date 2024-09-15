class_name WidgetFactory

extends Object


static func create_from_json(data: Dictionary) -> Widget:
	if data && data.has("type"):
		var type = Widget.WidgetType.get(data["type"])
		if type == Widget.WidgetType.PAGE_TITLE:
			return PageTitleWidget.new(data)
		elif type == Widget.WidgetType.ITEM_SEARCH:
			return ItemSearchWidget.new(data)
		elif type == Widget.WidgetType.TEXT:
			return TextWidget.new(data)

	return Widget.new(data)
