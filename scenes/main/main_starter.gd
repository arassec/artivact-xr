####################################################################################################
# Main script for Artivac XR's opening scene. Offers collection management functionality and 
# transits into the collection scene.
####################################################################################################
extends Node3D


# Indicates whether to initialize the collection selector or not.
var initCollectionSelector = true

# Indicates whether a download is currently in progress or not:
var downloadInProgress = false
# Delay before the status of downloads is updated in milliseconds:
var downloadStatusDelay = 10

# Indicates that the component must be initialized. Used to e.g. place the main menu panel when
# the user is sitting.
var initialize = true

# Filesize of a remote collection. Will be set before Downoad and used to calculate the progress.
var remoteCollectionFileSize: int = 0

# Background environment scene.
var backgroundSceneInstance


####################################################################################################
# Initializes the script:
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.MAIN_EXIT_APPLICATION, _exit_application)
	SignalBus.register(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION, _download_collection)
	SignalBus.register(SignalBus.SignalType.MAIN_OPEN_COLLECTION, _open_collection)
	SignalBus.register(SignalBus.SignalType.MAIN_DELETE_COLLECTION, _delete_collection)
	SignalBus.register(SignalBus.SignalType.MAIN_SETTING_CHANGED, _setting_changed)


####################################################################################################
# Cleans up signal registrations after the scene closed.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.MAIN_EXIT_APPLICATION, _exit_application)
	SignalBus.deregister(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION, _download_collection)
	SignalBus.deregister(SignalBus.SignalType.MAIN_OPEN_COLLECTION, _open_collection)
	SignalBus.deregister(SignalBus.SignalType.MAIN_DELETE_COLLECTION, _delete_collection)
	SignalBus.deregister(SignalBus.SignalType.MAIN_SETTING_CHANGED, _setting_changed)


####################################################################################################
# Sets display configurations, e.g. 4xMSAA.
####################################################################################################
func _ready():
	# Initialize Godot XR stuff:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	get_viewport().msaa_3d = Viewport.MSAA_4X

	# Apply settings:
	var musicVolume = SettingsStore.get_value(SettingsStore.SettingType.MUSIC_VOLUME)
	if musicVolume:
		$AudioStreamPlayer.volume_db = linear_to_db(musicVolume)

	var musicEnabled = SettingsStore.get_value(SettingsStore.SettingType.MUSIC_ENABLED)
	if musicEnabled:
		$AudioStreamPlayer.play()

	var rightHandActive = SettingsStore.get_value(SettingsStore.SettingType.ACTIVE_HAND)
	if rightHandActive:
		get_parent().find_child("CollectionMenuOpenXRCompositionLayerQuad").controller = get_parent().find_child("RightHand")
	else:
		get_parent().find_child("CollectionMenuOpenXRCompositionLayerQuad").controller = get_parent().find_child("LeftHand")

	var locale = SettingsStore.get_value(SettingsStore.SettingType.LOCALE)
	if locale == 0:
		TranslationServer.set_locale('en')
	elif locale == 1:
		TranslationServer.set_locale('de')
		

####################################################################################################
# Triggers an update of the selected collection info in the main UI panel. This is done here,
# because the info panel is a sub-scene and has to be initialized, first.
# The Update is only triggered the first time this method is called after start.
####################################################################################################
func _process(delta):
	if CollectionStore.is_sync_required():
		_update_remote_collection_infos()
		
	if initCollectionSelector:
		initCollectionSelector = false
		# Collect collection information from disk:
		CollectionStore.load_collection_infos()
		
	if downloadInProgress:
		downloadStatusDelay = downloadStatusDelay - (delta * 1000)
		if downloadStatusDelay < 0:
			downloadStatusDelay = 10
			SignalBus.trigger_with_payload(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION_PROGRESS, $RemoteArtivactServer.get_progress(remoteCollectionFileSize))

	if initialize:
		initialize = false
		var cam = get_parent().find_child("XRCamera3D")
		var collectionMenu = get_parent().find_child("DebugPanelOpenXRCompositionLayerQuad")
		if cam && collectionMenu:
			collectionMenu.transform.origin.y = (cam.transform.origin.y - 0.35)


####################################################################################################
# Closes the app on notification.
####################################################################################################
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit() # default behavior


####################################################################################################
# Exits the application.
####################################################################################################
func _exit_application():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


####################################################################################################
# Starts the download of the remote file containing information about available collections.
####################################################################################################
func _update_remote_collection_infos():
	CollectionStore.remove_content_export_overviews_file()
	$RemoteArtivactServer.get_collection_infos(_remote_collection_infos_updated, CollectionStore.contentExportOverviewsFile)


####################################################################################################
# Callback, called after remote collection information has been downloaded.
####################################################################################################
func _remote_collection_infos_updated(result, _response_code, _headers, _body):
	CollectionStore.load_collection_infos()
	if result != HTTPRequest.RESULT_SUCCESS:
		SignalBus.debug_json({"HTTP Error": result})


####################################################################################################
# Starts the download of the remote file containing information about available collections.
####################################################################################################
func _download_collection(collectionId: String):
	var collectionInfo = CollectionStore.get_collection_info(collectionId)
	if collectionInfo != null && collectionInfo.fileSizeRemote > 0:
		remoteCollectionFileSize = collectionInfo.fileSizeRemote
		$RemoteArtivactServer.download_collection(_download_collection_finished, collectionInfo.id)
		downloadInProgress = true
		CollectionStore.set_selected_collection(collectionId)


####################################################################################################
# Callback, called after remote collection information has been downloaded.
####################################################################################################
func _download_collection_finished(result, _response_code, _headers, _body):
	if result != HTTPRequest.RESULT_SUCCESS:
		SignalBus.debug_json({"HTTP-ERROR": result})

	SignalBus.trigger(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION_FINISHED)
	downloadInProgress = false
	
	CollectionStore.load_collection_infos()
	
	_open_collection(CollectionStore.get_selected_collection())


####################################################################################################
# Opens the currently selected collection by switching to the next scene.
####################################################################################################
func _open_collection(collectionId: String):
	CollectionStore.set_selected_collection(collectionId)
	
	# Find the XRToolsSceneBase ancestor of the current node
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		return
		
	# Request loading the next scene
	scene_base.load_scene("res://scenes/collection/collection.tscn")


####################################################################################################
# Deletes the file of the currently selected collection.
####################################################################################################
func _delete_collection(collectionId: String):
	var debug = {}
	debug["input"] = collectionId
	var collectionInfo = CollectionStore.get_collection_info(collectionId)
	debug["collectionInfo"] = collectionInfo
	SignalBus.debug_json(debug)
	if collectionInfo == null:
		return
	var fileToDelete = collectionInfo.localFile
	if fileToDelete.begins_with("user://"):
		CollectionStore.remove_collection_zip_reader(collectionInfo.id)
		DirAccess.remove_absolute(fileToDelete)
		CollectionStore.load_collection_infos()


####################################################################################################
# Reacts on setting changes.
####################################################################################################
func _setting_changed(setting: Dictionary) -> void:
	if setting.has(str(SettingsStore.SettingType.MUSIC_ENABLED)):
		var musicEnabled = setting[str(SettingsStore.SettingType.MUSIC_ENABLED)]
		if musicEnabled:
			$AudioStreamPlayer.play()
		else:
			$AudioStreamPlayer.stop()
	elif setting.has(str(SettingsStore.SettingType.MUSIC_VOLUME)):
		var musicVolume = setting[str(SettingsStore.SettingType.MUSIC_VOLUME)]
		$AudioStreamPlayer.volume_db = linear_to_db(musicVolume)
	elif setting.has(str(SettingsStore.SettingType.ACTIVE_HAND)):
		var rightHandActive = setting[str(SettingsStore.SettingType.ACTIVE_HAND)]
		if rightHandActive:
			get_parent().find_child("CollectionMenuOpenXRCompositionLayerQuad").controller = get_parent().find_child("RightHand")
		else:
			get_parent().find_child("CollectionMenuOpenXRCompositionLayerQuad").controller = get_parent().find_child("LeftHand")
	elif setting.has(str(SettingsStore.SettingType.LOCALE)):
		# If the locale changed -> reload collection infos:
		CollectionStore.load_collection_infos()
