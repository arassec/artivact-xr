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

var widgetContentDefaultPos: Vector3 = Vector3(0.0, 1.5, -3.5)
var widgetContentDefaultRot: Vector3 = Vector3(0.0, 0.0, 0.0)
var widgetContentLeftPos: Vector3 = Vector3(-2.5, 1.5, -3)
var widgetContentLeftRot: Vector3 = Vector3(0.0, 45.0, 0.0)

var curWidgetIndex = 0

####################################################################################################
# Registers for signals.
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.COLL_QUIT_COLLECTION, _quit_collection)
	SignalBus.register(SignalBus.SignalType.COLL_OPEN_PAGE, _open_page)
	SignalBus.register(SignalBus.SignalType.COLL_OPEN_WIDGET, _open_widget)
	SignalBus.register(SignalBus.SignalType.COLL_ITEM_SHOW_DATA, _show_or_hide_item_content.bind(true))
	SignalBus.register(SignalBus.SignalType.COLL_ITEM_HIDE_DATA, _show_or_hide_item_content.bind(false))
	SignalBus.register(SignalBus.SignalType.COLL_WIDGET_CONTENT_LEFT, _place_widget_content.bind(widgetContentLeftPos, widgetContentLeftRot))
	SignalBus.register(SignalBus.SignalType.COLL_WIDGET_CONTENT_CENTER, _place_widget_content.bind(widgetContentDefaultPos, widgetContentDefaultRot))
	SignalBus.register(SignalBus.SignalType.COLL_ITEM_SHOW_INFO, _show_or_hide_widget_content.bind(true))
	SignalBus.register(SignalBus.SignalType.COLL_ITEM_HIDE_INFO, _show_or_hide_widget_content.bind(false))

	_load_pages()
	_load_background()


####################################################################################################
# Deregisters from signals.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.COLL_QUIT_COLLECTION, _quit_collection)
	SignalBus.deregister(SignalBus.SignalType.COLL_OPEN_PAGE, _open_page)
	SignalBus.deregister(SignalBus.SignalType.COLL_OPEN_WIDGET, _open_widget)
	SignalBus.deregister(SignalBus.SignalType.COLL_ITEM_SHOW_DATA, _show_or_hide_item_content.bind(true))
	SignalBus.deregister(SignalBus.SignalType.COLL_ITEM_HIDE_DATA, _show_or_hide_item_content.bind(false))
	SignalBus.deregister(SignalBus.SignalType.COLL_WIDGET_CONTENT_LEFT, _place_widget_content.bind(widgetContentLeftPos, widgetContentLeftRot))
	SignalBus.deregister(SignalBus.SignalType.COLL_WIDGET_CONTENT_CENTER, _place_widget_content.bind(widgetContentDefaultPos, widgetContentDefaultRot))
	SignalBus.deregister(SignalBus.SignalType.COLL_ITEM_SHOW_INFO, _show_or_hide_widget_content.bind(true))
	SignalBus.deregister(SignalBus.SignalType.COLL_ITEM_HIDE_INFO, _show_or_hide_widget_content.bind(false))


####################################################################################################
# TODO
####################################################################################################
func _load_pages():
	collectionZipReader = CollectionStore.get_collection_zip_reader(CollectionStore.get_selected_collection())

	var artivactContentJson: ArtivactContentJson = CollectionStore.get_artivact_content_json(CollectionStore.get_selected_collection())
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
	_show_or_hide_item_content(false)
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_UPDATE_PAGE_NAV, menus)


####################################################################################################
# TODO
####################################################################################################
func _process(_delta):
	if initialize:
		initialize = false
		var cam = get_parent().find_child("XRCamera3D")
		var collectionMenu = get_parent().find_child("CollectionMenuOpenXRCompositionLayerQuad")
		if cam && collectionMenu:
			collectionMenu.transform.origin.y = (cam.transform.origin.y - 0.35)
		
	if openPage == true:
		openPage = false
		_open_page(menus[0].id)


####################################################################################################
# Creates fallback key handling to support testing the application without headset.
####################################################################################################
func _input(event):
	if event is InputEventKey && !event.pressed && event.keycode == Key.KEY_Q:
		SignalBus.trigger(SignalBus.SignalType.COLL_QUIT_COLLECTION)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_1:
		_open_page(menus[0].menuId)
		print(selectedPage)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_2:
		_open_page(menus[1].menuId)
		print(selectedPage)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_3:
		_open_page(menus[2].menuId)
		print(selectedPage)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_N:
		curWidgetIndex = curWidgetIndex + 1
		_open_widget(selectedPage.widgets[curWidgetIndex].id)
		print(selectedPage.widgets[curWidgetIndex].navigationTitle.translate())
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_P:
		curWidgetIndex = curWidgetIndex - 1
		_open_widget(selectedPage.widgets[curWidgetIndex].id)
		print(selectedPage.widgets[curWidgetIndex].navigationTitle.translate())


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
				break


####################################################################################################
# Quits the collection and transits to Artivact XR's main scene.
####################################################################################################
func _quit_collection():
	SignalBus.trigger(SignalBus.SignalType.COLL_ITEM_HIDE_DATA)
	# Find the XRToolsSceneBase ancestor of the current node
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		return
	# Request loading the next scene
	scene_base.exit_to_main_menu()


func _show_or_hide_item_content(visible: bool):
	var itemContentCompositionLayer = get_parent().find_child("ItemContentOpenXRCompositionLayerQuad")
	if itemContentCompositionLayer:
		itemContentCompositionLayer.visible = visible


func _place_widget_content(pos: Vector3, rot: Vector3):
	var widgetContentCompositionLayer: Node3D = get_parent().find_child("WidgetContentOpenXRCompositionLayerQuad")
	if widgetContentCompositionLayer:
		widgetContentCompositionLayer.position = pos
		widgetContentCompositionLayer.rotation = rot
		

func _show_or_hide_widget_content(visible: bool):
	var widgetContentCompositionLayer = get_parent().find_child("WidgetContentOpenXRCompositionLayerQuad")
	if widgetContentCompositionLayer:
		widgetContentCompositionLayer.visible = visible
