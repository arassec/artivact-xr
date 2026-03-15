####################################################################################################
# Main script for the collection scene. This is the base scene for the "in-collection" experience.
####################################################################################################
extends Node3D

var collectionZipReader: ZIPReader

var mainArtivactMenuJson: ArtivactMenuJson
var pages: Array[ArtivactPageContentJson] = []

# Contains the menu information to create the page navigation from:
var menus: Array[ArtivactMenuJson] = []

var artivactContentJson: ArtivactContentJson

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
	SignalBus.register(SignalBus.SignalType.COLL_CLOSE_WIDGET, _close_widget)
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
	SignalBus.deregister(SignalBus.SignalType.COLL_CLOSE_WIDGET, _close_widget)
	SignalBus.deregister(SignalBus.SignalType.MAIN_SETTING_CHANGED, _setting_changed)
	SignalBus.deregister(SignalBus.SignalType.CTRL_GRIP_PRESSED, _grip_pressed)
	SignalBus.deregister(SignalBus.SignalType.CTRL_GRIP_RELEASED, _grip_released)


####################################################################################################
# TODO
####################################################################################################
func _load_pages():
	collectionZipReader = CollectionStore.get_collection_zip_reader(CollectionStore.get_selected_collection())

	artivactContentJson = CollectionStore.get_artivact_content_json(CollectionStore.get_selected_collection())
	var data = CollectionStore.read_component_json_file(ComponentType.MENU, artivactContentJson.sourceIds[0])

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
	var data = CollectionStore.read_component_json_file(ComponentType.PAGE, id)
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

		# Fake a text widget to display the collection's general content description on the scondary panel:
		if artivactContentJson.title && artivactContentJson.content:
			var widgetData: Dictionary = {
				"heading": {
					"value": artivactContentJson.title.value,
					"translations": artivactContentJson.title.translations
				}, 
				"content": {
					"value": artivactContentJson.content.value,
					"translations": artivactContentJson.content.translations
				}
			}
			var widget = TextWidget.new(widgetData)
			var widgetSceneData: WidgetSceneData = WidgetSceneData.new()
			widgetSceneData.widget = widget
			widgetSceneData.secondaryPanelScene = "uid://28gvkovxs7vo"
			SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_UPDATE_WIDGET_CONTENT, widgetSceneData)
		else:
			get_parent().find_child("SecondaryPanelOpenXRCompositionLayerQuad").visible = false


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
					for widget in selectedPage.widgets:
						if widget is PageTitleWidget:
							CollectionStore.set_page_title_widget(widget)
							break;
					SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_UPDATE_WIDGET_NAV, page.widgets)


####################################################################################################
# TODO
####################################################################################################
func _open_widget(widgetId):
	SignalBus.trigger(SignalBus.SignalType.COLL_CLOSE_ITEM_MEDIA)

	if selectedPage != null:
		for widget in selectedPage.widgets:
			if widget.id == widgetId:
				get_parent().find_child("SecondaryPanelOpenXRCompositionLayerQuad").visible = true

				var widgetSceneData: WidgetSceneData = WidgetSceneData.new()

				widgetSceneData.widget = widget
				
				if widget is TextWidget:
					widgetSceneData.secondaryPanelScene = "uid://28gvkovxs7vo"
				elif widget is InfoBoxWidget:
					widgetSceneData.secondaryPanelScene = "uid://1kxrpw8wdics"
				elif widget is AvatarWidget:
					widgetSceneData.secondaryPanelScene = "uid://c3av7exx0tb53"
				elif widget is ItemSearchWidget:
					widgetSceneData.primaryPanelScene = "uid://423w5nqiguav"
					widgetSceneData.secondaryPanelScene = "uid://c4kqmp3ysj60r"
				elif widget is ImageGalleryWidget:
					widgetSceneData.primaryPanelScene = "uid://c2adlrcgfnenx"
					widgetSceneData.secondaryPanelScene = "uid://bn16unntpl8nj"

				SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_UPDATE_WIDGET_CONTENT, widgetSceneData)

				return


####################################################################################################
# TODO: The 'visible = false' is causing the app to crash when switching to the main menu!!!
####################################################################################################
func _close_widget():
	get_parent().find_child("SecondaryPanelOpenXRCompositionLayerQuad").visible = false
	SignalBus.trigger(SignalBus.SignalType.COLL_CLOSE_ITEM_MEDIA)


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
