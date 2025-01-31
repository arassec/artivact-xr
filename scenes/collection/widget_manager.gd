class_name WidgetManager

extends Node


var widgetLoaderThread: Thread

var widgetNode: Node3D
var widgetLoaded = false

var widgetSceneData: WidgetSceneData = WidgetSceneData.new()


func _process(_delta):
	if widgetLoaded:
		widgetLoaded = false
		if widgetNode:
			add_child(widgetNode)
		SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_UPDATE_WIDGET_CONTENT, widgetSceneData)


func replace_widget(widget: Widget):
	if widgetNode != null:
		remove_child(widgetNode)
		widgetNode.queue_free()
		widgetNode = null

	widgetLoaderThread = Thread.new()
	widgetLoaderThread.start(_load_widget.bind(widget), Thread.PRIORITY_LOW)


func _load_widget(widget: Widget):
	
	widgetSceneData.widget = widget
	
	if widget is PageTitleWidget:
		widgetSceneData.secondaryPanelScene = "res://scenes/collection/widgets/page_title/page_title_secondary.tscn"
	elif widget is TextWidget:
		widgetSceneData.secondaryPanelScene = "res://scenes/collection/widgets/text/text_secondary.tscn"
	elif widget is InfoBoxWidget:
		widgetSceneData.secondaryPanelScene = "res://scenes/collection/widgets/info_box/info_box_secondary.tscn"
	elif widget is AvatarWidget:
		widgetSceneData.secondaryPanelScene = "res://scenes/collection/widgets/avatar/avatar_secondary.tscn"
	elif widget is ImageTextWidget:
		widgetSceneData.primaryPanelScene = "res://scenes/collection/widgets/image_text/image_text_primary.tscn"
	elif widget is ItemSearchWidget:
		widgetSceneData.primaryPanelScene = "res://scenes/collection/widgets/item_search/item_search_primary.tscn"
		widgetSceneData.secondaryPanelScene = "res://scenes/collection/widgets/item_search/item_search_secondary.tscn"
		var scene: Resource = load("res://scenes/collection/widgets/item_search/item_search.tscn")
		widgetNode = scene.instantiate()
		widgetNode.initialize(widget)

	widgetLoaded = true
