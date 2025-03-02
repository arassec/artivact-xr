####################################################################################################
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
	SignalBus.register(SignalBus.SignalType.MAIN_SETTING_CHANGED, _setting_changed)
	SignalBus.register(SignalBus.SignalType.CTRL_GRIP_PRESSED, _grip_pressed)
	SignalBus.register(SignalBus.SignalType.CTRL_GRIP_RELEASED, _grip_released)

	_load_pages()


####################################################################################################
# Deregisters from signals.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.COLL_QUIT_COLLECTION, _quit_collection)
	SignalBus.deregister(SignalBus.SignalType.COLL_OPEN_PAGE, _open_page)
	SignalBus.deregister(SignalBus.SignalType.COLL_OPEN_WIDGET, _open_widget)
	SignalBus.deregister(SignalBus.SignalType.MAIN_SETTING_CHANGED, _setting_changed)
	SignalBus.deregister(SignalBus.SignalType.CTRL_GRIP_PRESSED, _grip_pressed)
	SignalBus.deregister(SignalBus.SignalType.CTRL_GRIP_RELEASED, _grip_released)


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
func _load_page(id: String):
	var data = CollectionStore.read_json_file(str(id, ".artivact.page-content.json"))
	var pageContentJson = ArtivactPageContentJson.new(data)
	pages.append(pageContentJson)


####################################################################################################
# TODO
####################################################################################################
func _ready():
	var musicVolume = SettingsStore.get_value(SettingsStore.SettingType.MUSIC_VOLUME)
	if musicVolume:
		$AudioStreamPlayer.volume_db = linear_to_db(musicVolume)
	
	var musicEnabled = SettingsStore.get_value(SettingsStore.SettingType.MUSIC_ENABLED)
	if musicEnabled:
		$AudioStreamPlayer.play()

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
	SignalBus.trigger(SignalBus.SignalType.COLL_CLOSE_ITEM_MEDIA)

	if selectedPage != null:
		for widget in selectedPage.widgets:
			if widget.id == widgetId:
				var widgetSceneData: WidgetSceneData = WidgetSceneData.new()

				widgetSceneData.widget = widget
				
				if widget is PageTitleWidget:
					widgetSceneData.secondaryPanelScene = "res://scenes/collection/widgets/page_title/page_title_secondary.tscn"
				elif widget is TextWidget:
					widgetSceneData.secondaryPanelScene = "res://scenes/collection/widgets/text/text_secondary.tscn"
				elif widget is InfoBoxWidget:
					widgetSceneData.secondaryPanelScene = "res://scenes/collection/widgets/info_box/info_box_secondary.tscn"
				elif widget is AvatarWidget:
					widgetSceneData.secondaryPanelScene = "res://scenes/collection/widgets/avatar/avatar_secondary.tscn"
				elif widget is ItemSearchWidget:
					widgetSceneData.primaryPanelScene = "res://scenes/collection/widgets/item_search/item_search_primary.tscn"
					widgetSceneData.secondaryPanelScene = "res://scenes/collection/widgets/item_search/item_search_secondary.tscn"

				SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_UPDATE_WIDGET_CONTENT, widgetSceneData)

				return


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


####################################################################################################
# Reacts on setting changes.
####################################################################################################
func _setting_changed(setting: Dictionary) -> void:
	if setting.has(str(SettingsStore.SettingType.ACTIVE_HAND)):
		var rightHandActive = setting[str(SettingsStore.SettingType.ACTIVE_HAND)]
		if rightHandActive:
			get_parent().find_child("PrimaryPanelOpenXRCompositionLayerQuad").controller = get_parent().find_child("RightHand")
			get_parent().find_child("SecondaryPanelOpenXRCompositionLayerQuad").controller = get_parent().find_child("RightHand")
		else:
			get_parent().find_child("PrimaryPanelOpenXRCompositionLayerQuad").controller = get_parent().find_child("LeftHand")
			get_parent().find_child("SecondaryPanelOpenXRCompositionLayerQuad").controller = get_parent().find_child("LeftHand")


func _grip_pressed(controller: XRController3D) -> void:
	get_parent().find_child("PrimaryPanelOpenXRCompositionLayerQuad").controller = null
	get_parent().find_child("SecondaryPanelOpenXRCompositionLayerQuad").controller = null
	
	
func _grip_released(controller: XRController3D) -> void:
	get_parent().find_child("PrimaryPanelOpenXRCompositionLayerQuad").controller = controller
	get_parent().find_child("SecondaryPanelOpenXRCompositionLayerQuad").controller = controller
