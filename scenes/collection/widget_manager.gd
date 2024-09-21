extends Node


var currentWidgetInstance = null
var widgetLoaderThread: Thread
var widgetLoaded = false


func _process(delta):
	if widgetLoaded:
		widgetLoaded = false
		add_child(currentWidgetInstance)
	

func replace_widget(widget: Widget):
	if currentWidgetInstance != null:
		remove_child(currentWidgetInstance)
		currentWidgetInstance.queue_free()
	
	widgetLoaderThread = Thread.new()
	widgetLoaderThread.start(_load_scene.bind(widget), Thread.PRIORITY_LOW)
	

func _load_scene(widget: Widget):
	var scene = null
	
	if widget is PageTitleWidget:
		scene = load("res://scenes/collection/widgets/page_title/page_title.tscn")
	elif widget is ItemSearchWidget:
		scene = load("res://scenes/collection/widgets/item_search/item_search.tscn")
	elif widget is TextWidget:
		scene = load("res://scenes/collection/widgets/text/text.tscn")

	if scene != null:
		currentWidgetInstance = scene.instantiate()
		currentWidgetInstance.initialize(widget)
		widgetLoaded = true
