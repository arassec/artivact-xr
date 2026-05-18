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

var voiceEnabled: bool = false

@export var tablet: Tablet
@export var tablet_open_xr_composition_layer_quad: OpenXRCompositionLayerQuad


####################################################################################################
# Registers for signals.
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.COLL_QUIT_COLLECTION, _quit_collection)
	SignalBus.register(SignalBus.SignalType.COLL_OPEN_PAGE, _open_page)
	SignalBus.register(SignalBus.SignalType.COLL_OPEN_WIDGET, _open_widget)
	SignalBus.register(SignalBus.SignalType.COLL_CLOSE_WIDGET, _close_widget)
	SignalBus.register(SignalBus.SignalType.COLL_RESUME_VOICE, _resume_voice)
	SignalBus.register(SignalBus.SignalType.COLL_PAUSE_VOICE, _pause_voice)
	SignalBus.register(SignalBus.SignalType.COLL_MODEL_GRIPPED, _model_gripped)

	_load_pages()


####################################################################################################
# Deregisters from signals.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.COLL_QUIT_COLLECTION, _quit_collection)
	SignalBus.deregister(SignalBus.SignalType.COLL_OPEN_PAGE, _open_page)
	SignalBus.deregister(SignalBus.SignalType.COLL_OPEN_WIDGET, _open_widget)
	SignalBus.deregister(SignalBus.SignalType.COLL_CLOSE_WIDGET, _close_widget)
	SignalBus.deregister(SignalBus.SignalType.COLL_RESUME_VOICE, _resume_voice)
	SignalBus.deregister(SignalBus.SignalType.COLL_PAUSE_VOICE, _pause_voice)
	SignalBus.deregister(SignalBus.SignalType.COLL_MODEL_GRIPPED, _model_gripped)


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
		$AmbientMusicStreamPlayer.volume_db = linear_to_db(musicVolume)
	
	var musicEnabled = SettingsStore.get_value(SettingsStore.SettingType.MUSIC_ENABLED)
	if musicEnabled:
		$AmbientMusicStreamPlayer.play()

	var voiceVolume = SettingsStore.get_value(SettingsStore.SettingType.VOICE_VOLUME)
	if voiceVolume:
		$AudioStreamPlayer.volume_db = linear_to_db(voiceVolume)
	
	voiceEnabled = SettingsStore.get_value(SettingsStore.SettingType.VOICE_ENABLED)

	if voiceEnabled:
		CollectionStore.play_audio_file(CollectionStore.get_selected_collection(), SettingsStore.get_locale(), $AudioStreamPlayer)

	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_UPDATE_PAGE_NAV, menus)


####################################################################################################
# TODO
####################################################################################################
func _process(_delta) -> void:
	if initialize:
		initialize = false

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
			get_parent().find_child("BeamerOpenXRCompositionLayerQuad").visible = false


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
# Called when a new Widget is opened. The widget scenes are prepared and the widget's audio is 
# played (if any).
####################################################################################################
func _open_widget(widgetId):
	SignalBus.trigger(SignalBus.SignalType.COLL_CLOSE_ITEM_MEDIA)

	if selectedPage != null:
		for widget in selectedPage.widgets:
			if widget.id == widgetId:
				get_parent().find_child("BeamerOpenXRCompositionLayerQuad").visible = true

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
					widgetSceneData.primaryPanelScene = "uid://bn16unntpl8nj"
					widgetSceneData.secondaryPanelScene = "uid://c2adlrcgfnenx"

				var widgetAudioFile = PathUtil.get_file_path(ComponentType.WIDGET, widgetId, "content-audio")

				if voiceEnabled:
					CollectionStore.play_audio_file(widgetAudioFile, SettingsStore.get_locale(), $AudioStreamPlayer)
				
				SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_UPDATE_WIDGET_CONTENT, widgetSceneData)

				return


####################################################################################################
# TODO: The 'visible = false' is causing the app to crash when switching to the main menu!!!
####################################################################################################
func _close_widget():
	# get_parent().find_child("BeamerOpenXRCompositionLayerQuad").visible = false
	$AudioStreamPlayer.stop()
	SignalBus.trigger(SignalBus.SignalType.COLL_CLOSE_ITEM_MEDIA)


####################################################################################################
# Quits the collection and transits to Artivact XR's main scene.
####################################################################################################
func _quit_collection():
	$AudioStreamPlayer.stop()
		
	# Find the XRToolsSceneBase ancestor of the current node
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		return
	# Request loading the next scene
	scene_base.exit_to_main_menu()


####################################################################################################
# Resumes the voice audio.
####################################################################################################
func _resume_voice():
	$AudioStreamPlayer.stream_paused = false
		

####################################################################################################
# Pauses the voice audio.
####################################################################################################
func _pause_voice():
	$AudioStreamPlayer.stream_paused = true


####################################################################################################
# Shows the tablet upon grip release
####################################################################################################
func _model_gripped(gripped: bool):
		if gripped:
			if tablet:
				tablet.visible = false
			if tablet_open_xr_composition_layer_quad:
				tablet_open_xr_composition_layer_quad.visible = false
		else:
			if tablet:
				tablet.visible = true
			if tablet_open_xr_composition_layer_quad:
				tablet_open_xr_composition_layer_quad.visible = true
