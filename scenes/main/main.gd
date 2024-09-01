####################################################################################################
# main.gd
#
# Main script for Artivac XR's opening scene. Offers collection management functionality and 
# transits into the collection scene.
####################################################################################################
extends Node3D

# Contains basic collection information for the main menu:
var collectionInfos: Array[CollectionInfo] = []
# The index of the currently selected collection info:
var currentCollectionInfo: int = -1

# Contains the collection ZIP readers, indexed by the collection's ID.
#    Collection ID -> ZIP Reader of the collection's ZIP file on disk
var collectionZipReaders: Dictionary = {}

# Contains the parsed content export JSON file, indexed by the collection's ID.
#    Collection ID -> ArtivactContentJson
var artivactContentJsons: Dictionary = {}

# Path to the file containing available content exports of the remote Artivact server:
var contentExportOverviewsFile = "user://artivact.content-export-overviews.zip"


####################################################################################################
# Initializes the script:
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.EXIT_APPLICATION, exit_application)
	SignalBus.register(SignalBus.SignalType.UPDATE_REMOTE_COLLECTION_INFOS, update_remote_collection_infos)
	SignalBus.register(SignalBus.SignalType.NEXT_COLLECTION_INFO, next_collection_info)
	SignalBus.register(SignalBus.SignalType.PREVIOUS_COLLECTION_INFO, previous_collection_info)
	SignalBus.register(SignalBus.SignalType.OPEN_COLLECTION, open_collection)

	# Collect collection information from disk:
	load_collection_infos()


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
func _process(_delta):
	if currentCollectionInfo == -1 && collectionInfos.size() > 0:
		currentCollectionInfo = 0
		SignalBus.trigger_with_multiload(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, collectionInfos[currentCollectionInfo], {"currentCollectionInfo": currentCollectionInfo, "totalCollectionInfos": collectionInfos.size()})


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
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_Q:
		SignalBus.trigger(SignalBus.SignalType.NEXT_COLLECTION_INFO)


####################################################################################################
# Cleans up signal registrations after the scene closed.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.EXIT_APPLICATION, exit_application)
	SignalBus.deregister(SignalBus.SignalType.UPDATE_REMOTE_COLLECTION_INFOS, update_remote_collection_infos)
	SignalBus.deregister(SignalBus.SignalType.NEXT_COLLECTION_INFO, next_collection_info)
	SignalBus.deregister(SignalBus.SignalType.PREVIOUS_COLLECTION_INFO, previous_collection_info)
	SignalBus.deregister(SignalBus.SignalType.OPEN_COLLECTION, open_collection)


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
	DirAccess.remove_absolute(contentExportOverviewsFile)
	load_collection_infos()
	$RemoteArtivactServer.get_collection_infos(_remote_collection_infos_updated, contentExportOverviewsFile)


####################################################################################################
# Callback, called after remote collection information has been downloaded.
####################################################################################################
func _remote_collection_infos_updated(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Could not synchronize with Artivact server!")

	merge_remote_collection_infos()


####################################################################################################
# Merges downloaded collection information into the already created from the local filesystem:
####################################################################################################
func merge_remote_collection_infos():
	var zipReader = ZIPReader.new()
	var openResult := zipReader.open(contentExportOverviewsFile)
	if openResult != OK:
		# File might not have been downloaded by the user...
		return

	var contentExportOverviewsJson := JSON.new()
	var contentExportOverviewsJsonFile = zipReader.read_file("artivact.content-export-overviews.json").get_string_from_utf8()
	var parseResult := contentExportOverviewsJson.parse(contentExportOverviewsJsonFile)
	if parseResult != OK:
		# TODO: Error handling!
		return

	var contentExportOverviews = contentExportOverviewsJson.data
	
	for rawContentExport in contentExportOverviews:
		if !rawContentExport.has("exportType") || !rawContentExport["exportType"] == "JSON":
			continue
			
		if !rawContentExport.has("zipped") || !rawContentExport["zipped"]:
			continue
		
		var contentExport = ContentExport.new(rawContentExport)
		var existingCollectionInfoUpdated = false
		for collectionInfo in collectionInfos:
			if collectionInfo.id == contentExport.id:
				collectionInfo.update_online_data(contentExport)
				existingCollectionInfoUpdated = true
				
		if !existingCollectionInfoUpdated:
			var newCollectionInfo = CollectionInfo.new(contentExport.id)
			newCollectionInfo.update_online_data(contentExport)
			
			for fileInZip in zipReader.get_files():
				if fileInZip.begins_with(newCollectionInfo.id):
					var img = zipReader.read_file(fileInZip)
					var coverPicture = Image.new()
					var loadResult = ERR_UNAVAILABLE
					if fileInZip.ends_with("jpg") || fileInZip.ends_with("JPG") || fileInZip.ends_with("jpeg") || fileInZip.ends_with("JPEG"):
						loadResult = coverPicture.load_jpg_from_buffer(img)
					elif fileInZip.ends_with("png") || fileInZip.ends_with("PNG"):
						loadResult = coverPicture.load_png_from_buffer(img)
					if loadResult == OK:
						newCollectionInfo.set_cover_picture(ImageTexture.create_from_image(coverPicture))
				
			collectionInfos.append(newCollectionInfo)

	SignalBus.trigger_with_multiload(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, collectionInfos[currentCollectionInfo], {"currentCollectionInfo": currentCollectionInfo, "totalCollectionInfos": collectionInfos.size()})


####################################################################################################
# Loads collection information. First from local content export files found in the filesystem, and 
# afterwards from the downloaded remote file with information about available collections, if it 
# exists.
####################################################################################################
func load_collection_infos():
	collectionInfos.clear()
	var resourceFiles = DirAccess.get_files_at("res://")
	for resourceFile in resourceFiles:
		if resourceFile.ends_with(".artivact.content.json.zip"):
			load_collection_info("res://", resourceFile)
	resourceFiles = DirAccess.get_files_at("user://")
	for resourceFile in resourceFiles:
		if resourceFile.ends_with(".artivact.content.json.zip"):
			load_collection_info("user://", resourceFile)
	merge_remote_collection_infos()


####################################################################################################
# Loads collection info from a local Artivact content export file
####################################################################################################
func load_collection_info(locationPrefix: String, collectionFile: String):
	var collectionId = collectionFile.replace(".artivact.content.json.zip", "")
	var collectionZipFile = str("res://", collectionFile)
	var collectionJsonFile = "artivact.content.json"
	
	var zipReader = ZIPReader.new()
	var openResult := zipReader.open(collectionZipFile)
	if openResult != OK:
		# TODO: Error handling!
		return
	
	var collectionJson := JSON.new()
	var collectionJsonString = zipReader.read_file(collectionJsonFile).get_string_from_utf8()
	var parseResult := collectionJson.parse(collectionJsonString)
	if parseResult != OK:
		# TODO: Error handling!
		return

	var collectionData = collectionJson.data

	# Save the parsed content JSON containing properties and tags:	
	artivactContentJsons[collectionId] = ArtivactContentJson.new(collectionData)
	
	# Save the ZIP reader for the collection file:
	collectionZipReaders[collectionId] = zipReader
	
	# Create collection info for the main menu:
	var lastModified = FileAccess.get_modified_time(collectionZipFile)
	var file := FileAccess.open(collectionZipFile, FileAccess.READ)
	var fileSize = file.get_length()
	collectionInfos.append(CollectionInfo.new(collectionId, artivactContentJsons[collectionId], lastModified, fileSize, str(locationPrefix, collectionFile)))


####################################################################################################
# Switches to the next collection information.
####################################################################################################
func next_collection_info():
	if currentCollectionInfo < (collectionInfos.size() -1):
		currentCollectionInfo = currentCollectionInfo + 1
		SignalBus.trigger_with_multiload(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, collectionInfos[currentCollectionInfo], {"currentCollectionInfo": currentCollectionInfo, "totalCollectionInfos": collectionInfos.size()})


####################################################################################################
# Switches to the previous collection information.
####################################################################################################
func previous_collection_info():
	if currentCollectionInfo > 0:
		currentCollectionInfo = currentCollectionInfo -1
		SignalBus.trigger_with_multiload(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, collectionInfos[currentCollectionInfo], {"currentCollectionInfo": currentCollectionInfo, "totalCollectionInfos": collectionInfos.size()})


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
