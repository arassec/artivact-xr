class_name ArtivactPageContentJson

extends Object

var id: String
var widgets: Array[Widget] = []


func _init(data: Dictionary):
	if data:
		if data.has("id") and data["id"] != null:
			id = data["id"]
		if data.has("widgets") and data["widgets"] is Array:
			for widgetJson in data["widgets"]:
				var widget = WidgetFactory.create_from_json(widgetJson)
				if widget.type != Widget.WidgetType.UNSUPPORTED:
					widgets.append(widget)
