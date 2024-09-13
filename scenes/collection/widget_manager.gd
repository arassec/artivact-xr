extends Node

var currentWidgetInstance


func replace_widget(widget: Widget):
	if currentWidgetInstance != null:
		remove_child(currentWidgetInstance)
		currentWidgetInstance.queue_free()
	
	var scene = null
	
	if widget is PageTitleWidget:
		scene = load("res://scenes/collection/widgets/page_title/page_title.tscn")
	elif widget is ItemSearchWidget:
		scene = load("res://scenes/collection/widgets/item_search/item_search.tscn")

	if scene != null:
		currentWidgetInstance = scene.instantiate()
		currentWidgetInstance.initialize(widget)
		add_child(currentWidgetInstance)
