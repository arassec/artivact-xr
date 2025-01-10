extends Node


var loadedWidget
var widgetLoaderThread: Thread

var widgetNode: Node
var widgetLoaded = false

var widgetContentSceneData = {}
var updateWidgetContent = false


func _process(delta):
	if widgetLoaded:
		widgetLoaded = false

		if updateWidgetContent:
			SignalBus.trigger_with_payload(SignalBus.SignalType.WIDGET_CONTENT_LOAD, widgetContentSceneData)
		else:
			SignalBus.trigger(SignalBus.SignalType.WIDGET_CONTENT_CLEAR)

		if widgetNode:
			add_child(widgetNode)


func replace_widget(widget: Widget):
	loadedWidget = widget
	
	if widgetNode != null:
		remove_child(widgetNode)
		widgetNode.queue_free()
		widgetNode = null
	
	widgetLoaderThread = Thread.new()
	widgetLoaderThread.start(_load_widget.bind(widget), Thread.PRIORITY_LOW)


func _load_widget(widget: Widget):
	updateWidgetContent = false
	
	widgetContentSceneData["widget"] = widget
	
	if widget is PageTitleWidget:
		widgetContentSceneData["scene"] = "res://scenes/collection/widgets/page_title/page_title_content.tscn"
		updateWidgetContent = true
	elif widget is TextWidget:
		widgetContentSceneData["scene"] = "res://scenes/collection/widgets/text/text_content.tscn"
		updateWidgetContent = true
	elif widget is ItemSearchWidget:
		var scene: Resource = load("res://scenes/collection/widgets/item_search/item_search.tscn")
		widgetNode = scene.instantiate()
		widgetNode.initialize(widget)

	widgetLoaded = true
