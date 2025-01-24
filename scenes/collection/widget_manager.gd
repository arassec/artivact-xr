extends Node


var loadedWidget
var widgetLoaderThread: Thread

var widgetNode: Node3D
var widgetLoaded = false

var widgetContentSceneData = {}
var updateWidgetContent = false


var curWidgetContentPosCenter = true
var placeWidgetContentCenter = true


func _process(delta):
	if widgetLoaded:
		widgetLoaded = false

		if placeWidgetContentCenter && !curWidgetContentPosCenter:
			curWidgetContentPosCenter = true
			SignalBus.trigger(SignalBus.SignalType.COLL_WIDGET_CONTENT_CENTER)
		elif !placeWidgetContentCenter && curWidgetContentPosCenter:
			curWidgetContentPosCenter = false
			SignalBus.trigger(SignalBus.SignalType.COLL_WIDGET_CONTENT_LEFT)

		if updateWidgetContent:
			SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_UPDATE_WIDGET_CONTENT, widgetContentSceneData)

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
		placeWidgetContentCenter = true
	elif widget is TextWidget:
		widgetContentSceneData["scene"] = "res://scenes/collection/widgets/text/text_content.tscn"
		updateWidgetContent = true
		placeWidgetContentCenter = true
	elif widget is InfoBoxWidget:
		widgetContentSceneData["scene"] = "res://scenes/collection/widgets/info_box/info_box_content.tscn"
		updateWidgetContent = true
		placeWidgetContentCenter = true
	elif widget is AvatarWidget:
		widgetContentSceneData["scene"] = "res://scenes/collection/widgets/avatar/avatar_content.tscn"
		updateWidgetContent = true
		placeWidgetContentCenter = true
	elif widget is ImageTextWidget:
		widgetContentSceneData["scene"] = "res://scenes/collection/widgets/image_text/image_text_content.tscn"
		updateWidgetContent = true
		placeWidgetContentCenter = true
	elif widget is ItemSearchWidget:
		widgetContentSceneData["scene"] = "res://scenes/collection/widgets/item_search/item_search_content.tscn"
		updateWidgetContent = true
		placeWidgetContentCenter = false
		var scene: Resource = load("res://scenes/collection/widgets/item_search/item_search.tscn")
		widgetNode = scene.instantiate()
		widgetNode.initialize(widget)

	widgetLoaded = true
