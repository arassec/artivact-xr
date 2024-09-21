####################################################################################################
# main.gd
#
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


####################################################################################################
# Initializes the script:
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.EXIT_APPLICATION, exit_application)
	SignalBus.register(SignalBus.SignalType.UPDATE_REMOTE_COLLECTION_INFOS, update_remote_collection_infos)
	SignalBus.register(SignalBus.SignalType.NEXT_COLLECTION_INFO, next_collection_info)
	SignalBus.register(SignalBus.SignalType.PREVIOUS_COLLECTION_INFO, previous_collection_info)
	SignalBus.register(SignalBus.SignalType.DOWNLOAD_COLLECTION, download_collection)
	SignalBus.register(SignalBus.SignalType.OPEN_COLLECTION, open_collection)
	SignalBus.register(SignalBus.SignalType.DELETE_COLLECTION, delete_collection_file)


####################################################################################################
# Sets display configurations, e.g. 4xMSAA.
####################################################################################################
func _ready():
	# Initialize Godot XR stuff:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	get_viewport().msaa_3d = Viewport.MSAA_4X


####################################################################################################
# Triggers an update of the selected collection info in the main UI panel. This is done here,
# because the info panel is a sub-scene and has to be initialized, first.
# The Update is only triggered the first time this method is called after start.
####################################################################################################
func _process(delta):
	if initCollectionSelector:
		initCollectionSelector = false
		# Collect collection information from disk:
		CollectionStore.load_collection_infos()
		
	if downloadInProgress:
		downloadStatusDelay = downloadStatusDelay - (delta * 1000)
		if downloadStatusDelay < 0:
			downloadStatusDelay = 10
			SignalBus.trigger_with_payload(SignalBus.SignalType.DOWNLOAD_COLLECTION_PROGRESS, $RemoteArtivactServer.get_progress(CollectionStore.get_collection_info().fileSizeRemote))


####################################################################################################
# Configures fallback keyboard shortcuts to test the application without XR device.
####################################################################################################
func _input(event):
	if event is InputEventKey && !event.pressed && event.keycode == Key.KEY_O:
		SignalBus.trigger(SignalBus.SignalType.OPEN_COLLECTION)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_E:
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_S:
		SignalBus.trigger(SignalBus.SignalType.UPDATE_REMOTE_COLLECTION_INFOS)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_P:
		SignalBus.trigger(SignalBus.SignalType.PREVIOUS_COLLECTION_INFO)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_N:
		SignalBus.trigger(SignalBus.SignalType.NEXT_COLLECTION_INFO)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_D:
		SignalBus.trigger(SignalBus.SignalType.DOWNLOAD_COLLECTION)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_X:
		SignalBus.trigger(SignalBus.SignalType.DELETE_COLLECTION)


####################################################################################################
# Cleans up signal registrations after the scene closed.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.EXIT_APPLICATION, exit_application)
	SignalBus.deregister(SignalBus.SignalType.UPDATE_REMOTE_COLLECTION_INFOS, update_remote_collection_infos)
	SignalBus.deregister(SignalBus.SignalType.NEXT_COLLECTION_INFO, next_collection_info)
	SignalBus.deregister(SignalBus.SignalType.PREVIOUS_COLLECTION_INFO, previous_collection_info)
	SignalBus.deregister(SignalBus.SignalType.DOWNLOAD_COLLECTION, download_collection)
	SignalBus.deregister(SignalBus.SignalType.OPEN_COLLECTION, open_collection)
	SignalBus.deregister(SignalBus.SignalType.DELETE_COLLECTION, delete_collection_file)


####################################################################################################
# Closes the app on notification.
####################################################################################################
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit() # default behavior


####################################################################################################
# Exits the application.
####################################################################################################
func exit_application():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


####################################################################################################
# Starts the download of the remote file containing information about available collections.
####################################################################################################
func update_remote_collection_infos():
	CollectionStore.remove_content_export_overviews_file()
	$RemoteArtivactServer.get_collection_infos(_remote_collection_infos_updated, CollectionStore.contentExportOverviewsFile)


####################################################################################################
# Callback, called after remote collection information has been downloaded.
####################################################################################################
func _remote_collection_infos_updated(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		SignalBus.trigger_with_payload(SignalBus.SignalType.COLLECTION_INFOS_UPDATED, false)
	else:
		SignalBus.trigger_with_payload(SignalBus.SignalType.COLLECTION_INFOS_UPDATED, true)		
	CollectionStore.load_collection_infos()


####################################################################################################
# Starts the download of the remote file containing information about available collections.
####################################################################################################
func download_collection():
	var collectionInfo = CollectionStore.get_collection_info()
	if collectionInfo != null && collectionInfo.fileSizeRemote > 0:
		$RemoteArtivactServer.download_collection(_download_collection_finished, collectionInfo.id)
		downloadInProgress = true


####################################################################################################
# Callback, called after remote collection information has been downloaded.
####################################################################################################
func _download_collection_finished(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		SignalBus.trigger_with_payload(SignalBus.SignalType.DOWNLOAD_COLLECTION_FINISHED, false)
	else:
		SignalBus.trigger_with_payload(SignalBus.SignalType.DOWNLOAD_COLLECTION_FINISHED, true)	
	downloadInProgress = false
	CollectionStore.load_collection_infos()


####################################################################################################
# Switches to the next collection information.
####################################################################################################
func next_collection_info():
	CollectionStore.next_collection_info()


####################################################################################################
# Switches to the previous collection information.
####################################################################################################
func previous_collection_info():
	CollectionStore.previous_collection_info()


####################################################################################################
# Opens the currently selected collection by switching to the next scene.
####################################################################################################
func open_collection():
	# Find the XRToolsSceneBase ancestor of the current node
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		return
	# Request loading the next scene
	scene_base.load_scene("res://scenes/collection/collection_main.tscn")


####################################################################################################
# Deletes the file of the currently selected collection.
####################################################################################################
func delete_collection_file():
	var collectionInfo = CollectionStore.get_collection_info()
	if collectionInfo == null:
		return
	var fileToDelete = collectionInfo.localFile
	if fileToDelete.begins_with("user://"):
		CollectionStore.remove_collection_zip_reader(collectionInfo.id)
		DirAccess.remove_absolute(fileToDelete)
		CollectionStore.load_collection_infos()
