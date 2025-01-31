####################################################################################################
# collection_main.gd
#
# Main script for the collection scene. This is the base scene for the "in-collection" experience.
####################################################################################################
extends Node3D

var collectionZipReader: ZIPReader

var mainArtivactMenuJson: ArtivactMenuJson
var pages: Array[ArtivactPageContentJson] = []

# Contains the menu information to create the page navigation from:
var menus: Array[ArtivactMenuJson] = []

var initialize = true

var selectedPage: ArtivactPageContentJson

var backgroundSceneInstance

var curWidgetIndex = 0

####################################################################################################
# Registers for signals.
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.COLL_QUIT_COLLECTION, _quit_collection)
	SignalBus.register(SignalBus.SignalType.COLL_OPEN_PAGE, _open_page)
	SignalBus.register(SignalBus.SignalType.COLL_OPEN_WIDGET, _open_widget)

	_load_pages()
	_load_background()


####################################################################################################
# Deregisters from signals.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.COLL_QUIT_COLLECTION, _quit_collection)
	SignalBus.deregister(SignalBus.SignalType.COLL_OPEN_PAGE, _open_page)
	SignalBus.deregister(SignalBus.SignalType.COLL_OPEN_WIDGET, _open_widget)


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
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_UPDATE_PAGE_NAV, menus)


####################################################################################################
# TODO
####################################################################################################
func _process(_delta) -> void:
	if initialize:
		initialize = false
		var cam = get_parent().find_child("XRCamera3D")
		var debugPanel = get_parent().find_child("DebugPanelOpenXRCompositionLayerQuad")
		if cam && debugPanel:
			debugPanel.transform.origin.y = (cam.transform.origin.y - 0.35)


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
	# Find the XRToolsSceneBase ancestor of the current node
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		return
	# Request loading the next scene
	scene_base.exit_to_main_menu()
