####################################################################################################
# collection_main.gd
#
# Main script for the collection scene. This is the base scene for the "in-collection" experience.
####################################################################################################
extends Node3D

var collectionZipReader: ZIPReader

var mainArtivactMenuJson: ArtivactMenuJson
var pages: Array[ArtivactPageContentJson] = []

# Contains the menu information to create the left-hand page navigation from:
var menus: Array[ArtivactMenuJson] = []

var initialize = true

var openPage = true
var selectedPage: ArtivactPageContentJson

var backgroundSceneInstance


####################################################################################################
# Registers for signals.
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.COLL_QUIT_COLLECTION, _quit_collection)
	SignalBus.register(SignalBus.SignalType.COLL_OPEN_PAGE, _open_page)
	SignalBus.register(SignalBus.SignalType.COLL_OPEN_WIDGET, _open_widget)
	SignalBus.register(SignalBus.SignalType.WIDGET_CONTENT_LOAD, _show_widget_content)
	SignalBus.register(SignalBus.SignalType.WIDGET_CONTENT_CLEAR, _hide_widget_content)

	_load_pages()
	_load_background()


####################################################################################################
# Deregisters from signals.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.COLL_QUIT_COLLECTION, _quit_collection)
	SignalBus.deregister(SignalBus.SignalType.COLL_OPEN_PAGE, _open_page)
	SignalBus.deregister(SignalBus.SignalType.COLL_OPEN_WIDGET, _open_widget)
	SignalBus.deregister(SignalBus.SignalType.WIDGET_CONTENT_LOAD, _show_widget_content)
	SignalBus.deregister(SignalBus.SignalType.WIDGET_CONTENT_CLEAR, _hide_widget_content)
	

####################################################################################################
# TODO
####################################################################################################
func _load_pages():
	collectionZipReader = CollectionStore.get_collection_zip_reader()

	var artivactContentJson: ArtivactContentJson = CollectionStore.get_artivact_content_json()
	var data = CollectionStore.read_json_file(str(artivactContentJson.sourceId, ".artivact.menu.json"))

	mainArtivactMenuJson = ArtivactMenuJson.new(data)
	
	if mainArtivactMenuJson.targetPageId != "":
		# Single-Page export:
		menus.append(mainArtivactMenuJson)
		_load_page(mainArtivactMenuJson.targetPageId)
	elif mainArtivactMenuJson.menuEntries.size() > 0:
		# Multi-Page export:
		for menuEntry in mainArtivactMenuJson.menuEntries:
			if menuEntry.targetPageId != "":
				menus.append(menuEntry)
				_load_page(menuEntry.targetPageId)
		
	
####################################################################################################
# TODO
####################################################################################################
func _load_background():
	var backgroundScene = load("res://scenes/collection/backgrounds/default/default_background.tscn")
	if backgroundScene != null:
		backgroundSceneInstance = backgroundScene.instantiate()
		add_child(backgroundSceneInstance)


	
####################################################################################################
# TODO
####################################################################################################
func _load_page(id: String):
	var data = CollectionStore.read_json_file(str(id, ".artivact.page-content.json"))
	var pageContentJson = ArtivactPageContentJson.new(data)
	pages.append(pageContentJson)


####################################################################################################
# TODO
####################################################################################################
func _ready():
	# OpenXR Reference Space is set to "Local" in the project settings. So we have to set the
	# camera's position manually here:
	#get_parent().find_child("XROrigin3D").set_position(Vector3(0, 1.8, 0))

	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_UPDATE_PAGE_NAV, menus)


####################################################################################################
# TODO
####################################################################################################
func _process(_delta):
	if openPage == true:
		openPage = false
		_open_page(menus[0].id)


####################################################################################################
# Creates fallback key handling to support testing the application without headset.
####################################################################################################
func _input(event):
	if event is InputEventKey && !event.pressed && event.keycode == Key.KEY_Q:
		SignalBus.trigger(SignalBus.SignalType.COLL_QUIT_COLLECTION)


####################################################################################################
# TODO
####################################################################################################
func _open_page(menuId):
	for menu in menus:
		if menu.id == menuId:
			var pageId = menu.targetPageId
			for page in pages:
				if page.id == pageId:
					selectedPage = page
					SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_UPDATE_WIDGET_NAV, page.widgets)
					_open_widget(page.widgets[0].id)


####################################################################################################
# TODO
####################################################################################################
func _open_widget(widgetId):
	if selectedPage != null:
		for widget in selectedPage.widgets:
			if widget.id == widgetId:
				$WidgetManager.replace_widget(widget)


####################################################################################################
# Quits the collection and transits to Artivact XR's main scene.
####################################################################################################
func _quit_collection():
		# Find the XRToolsSceneBase ancestor of the current node
		var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
		if not scene_base:
			return
		# Request loading the next scene
		scene_base.exit_to_main_menu()


func _show_widget_content(sceneData: Dictionary):
	var widgetContentCompositionLayer = get_parent().find_child("WidgetContentOpenXRCompositionLayerQuad")
	if widgetContentCompositionLayer:
		widgetContentCompositionLayer.visible = true


func _hide_widget_content():
	var widgetContentCompositionLayer = get_parent().find_child("WidgetContentOpenXRCompositionLayerQuad")
	if widgetContentCompositionLayer:
		widgetContentCompositionLayer.visible = false
