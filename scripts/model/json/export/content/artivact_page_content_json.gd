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
				widgets.append(WidgetFactory.create_from_json(widgetJson))
