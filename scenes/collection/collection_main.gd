####################################################################################################
# collection_main.gd
#
# Main script for the collection scene. This is the base scene for the "in-collection" experience.
####################################################################################################
extends Node

var collectionZipReader: ZIPReader

var mainArtivactMenuJson: ArtivactMenuJson
var pages: Array[ArtivactPageContentJson] = []

# Contains the menu information to create the left-hand page navigation from:
var menus: Array[ArtivactMenuJson] = []

var initialize = true

var openPage = true
var selectedPage: ArtivactPageContentJson


####################################################################################################
# Registers for signals.
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.QUIT_COLLECTION, _quit_collection)
	SignalBus.register(SignalBus.SignalType.OPEN_PAGE, _open_page)
	SignalBus.register(SignalBus.SignalType.OPEN_WIDGET, _open_widget)

	_load_pages()


####################################################################################################
# TODO
####################################################################################################
func _load_pages():
	collectionZipReader = CollectionStore.get_collection_zip_reader()

	var artivactContentJson: ArtivactContentJson = CollectionStore.get_artivact_content_json()
	var data = CollectionStore.read_json_file(str(artivactContentJson.menuId, ".artivact.menu.json"))

	mainArtivactMenuJson = ArtivactMenuJson.new(data)
	
	if mainArtivactMenuJson.targetPageId != "":
		# Single-Page export:
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
func _load_page(id: String):
	var data = CollectionStore.read_json_file(str(id, ".artivact.page-content.json"))
	var pageContentJson = ArtivactPageContentJson.new(data)
	pages.append(pageContentJson)


####################################################################################################
# TODO
####################################################################################################
func _ready():
	if menus.size() > 0:
		SignalBus.trigger_with_payload(SignalBus.SignalType.UPDATE_PAGE_NAVIGATION, menus)


####################################################################################################
# TODO
####################################################################################################
func _process(delta):
	if openPage == true && menus.size() > 0:
		openPage = false
		_open_page(menus[0].targetPageId)


####################################################################################################
# Creates fallback key handling to support testing the application without headset.
####################################################################################################
func _input(event):
	if event is InputEventKey && !event.pressed && event.keycode == Key.KEY_Q:
		SignalBus.trigger(SignalBus.SignalType.QUIT_COLLECTION)


####################################################################################################
# Deregisters from signals.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.QUIT_COLLECTION, _quit_collection)
	SignalBus.deregister(SignalBus.SignalType.OPEN_PAGE, _open_page)
	SignalBus.deregister(SignalBus.SignalType.OPEN_WIDGET, _open_widget)


####################################################################################################
# TODO
####################################################################################################
func _open_page(pageId):
	for page in pages:
		if page.id == pageId:
			selectedPage = page
			SignalBus.trigger_with_payload(SignalBus.SignalType.UPDATE_WIDGET_NAVIGATION, page.widgets)
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
