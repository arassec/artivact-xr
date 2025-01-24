class_name ArtivactPageContentJson

extends Object

var id: String
var widgets: Array[Widget] = []


func _init(data: Dictionary):
	if data:
		if data.has("id"):
			id = data["id"]
		if data.has("widgets"):
			for widgetJson in data["widgets"]:
				var widget = WidgetFactory.create_from_json(widgetJson)
				if not widget is SpaceWidget:
					widgets.append(widget)
