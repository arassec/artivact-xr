extends Node

# Indicates that the collection information should be synchronized.
var synchronizeCollectionInfosOnFirstStart = true

# Path to the file containing available collection exports of the remote Artivact instance:
var contentExportOverviewsFile = "user://artivact.collection-export-overviews.zip"

# Contains basic collection information:
var collectionInfos: Array[CollectionInfo] = []

# Contains the collection ZIP readers, indexed by the collection's ID.
#    Collection ID -> ZIP Reader of the collection's ZIP file on disk
var collectionZipReaders: Dictionary = {}

# Contains the parsed content export JSON file, indexed by the collection's ID.
#    Collection ID -> ArtivactContentJson
var artivactContentJsons: Dictionary = {}

# Contains the collection's properties configuration, indexed by the collection's ID.
#    Collection ID -> ArtivactPropertiesConfigurationJson
var artivactPropertiesConfigurationJsons: Dictionary = {}

# Thread for loading collection infos in the background.
var loadCollectionInfosThread: Thread

# Contains the ID of the currently selected collection.
var selectedCollectionId: String

# PageTitleWidget of the current collection, if any.
var currentCollectionPageTitleWidget: PageTitleWidget = null

# Contains all audio files that have already been played.
var playedAudioFiles: Array[String] = []


func _process(_delta) -> void:
	if loadCollectionInfosThread != null:
		if loadCollectionInfosThread.is_started() && !loadCollectionInfosThread.is_alive():
			loadCollectionInfosThread.wait_to_finish()
			loadCollectionInfosThread = null
			SignalBus.trigger(SignalBus.SignalType.MAIN_COLLECTION_INFOS_UPDATED)


func is_sync_required() -> bool:
	if synchronizeCollectionInfosOnFirstStart:
		synchronizeCollectionInfosOnFirstStart = false
		return true
	else:
		return false
		

func get_collection_info(collectionId: String) -> CollectionInfo:
	for collectionInfo in collectionInfos:
		if collectionInfo.id == collectionId:
			return collectionInfo
	return null


func get_collection_zip_reader(collectionId: String) -> ZIPReader:
	if collectionZipReaders.has(collectionId):
		return collectionZipReaders[collectionId]
	return null
	

func get_artivact_content_json(collectionId: String) -> ArtivactContentJson:
	if artivactContentJsons.has(collectionId):
		return artivactContentJsons[collectionId]
	return null
	

func get_artivact_properties_configuration_json(collectionId: String) -> ArtivactPropertiesConfigurationJson:
	if artivactPropertiesConfigurationJsons.has(collectionId):
		return artivactPropertiesConfigurationJsons[collectionId]
	return null


func set_selected_collection(collectionId: String) -> void:
	selectedCollectionId = collectionId
	playedAudioFiles.clear()


func get_selected_collection() -> String:
	return selectedCollectionId
	

func set_collection_zip_reader(collectionId: String, zipReader: ZIPReader):
	if collectionZipReaders[collectionId] != null:
		collectionZipReaders[collectionId].close()
	collectionZipReaders[collectionId] = zipReader


func remove_collection_zip_reader(collectionId: String):
	if collectionZipReaders.has(collectionId):
		collectionZipReaders[collectionId].close()
		collectionZipReaders.erase(collectionId)


func remove_content_export_overviews_file():
	DirAccess.remove_absolute(contentExportOverviewsFile)


func load_collection_infos():
	if loadCollectionInfosThread != null:
		return
	collectionInfos.clear()
	loadCollectionInfosThread = Thread.new()
	loadCollectionInfosThread.start(_load_collection_infos)


func set_page_title_widget(pageTitleWidget: PageTitleWidget) -> void:
	currentCollectionPageTitleWidget = pageTitleWidget
	

func get_page_title_widget() -> PageTitleWidget:
	return currentCollectionPageTitleWidget
	

####################################################################################################
# TODO
####################################################################################################
func read_json_file(jsonFile: String) -> Dictionary:
	var json := JSON.new()
	var jsonString = get_collection_zip_reader(selectedCollectionId).read_file(jsonFile).get_string_from_utf8()
	var parseResult := json.parse(jsonString)
	
	if parseResult != OK:
		# TODO: Error handling!
		return {}
		
	var result = json.data
	if json.data is Array:
		result = { "values": json.data}

	return result


####################################################################################################
# TODO
####################################################################################################
func play_audio_file(filepath: String, locale: String, player: AudioStreamPlayer) -> void:
	if player.is_playing():
		player.stop()

	if locale:
		filepath += "-" + locale
	
	var mp3Bytes = get_collection_zip_reader(selectedCollectionId).read_file(filepath + ".mp3")

	if !mp3Bytes.is_empty() and !playedAudioFiles.has(filepath):
		playedAudioFiles.append(filepath)
		var stream := AudioStreamMP3.new()
		stream.data = mp3Bytes
		player.stream = stream
		player.play()
	

####################################################################################################
# TODO
####################################################################################################
func read_component_json_file(type: ComponentType, id: String) -> Dictionary:
	var jsonFilePath = PathUtil.get_default_file_path(type, id)
	var json := JSON.new()
	var jsonString = get_collection_zip_reader(selectedCollectionId).read_file(jsonFilePath).get_string_from_utf8()
	var parseResult := json.parse(jsonString)
	
	if parseResult != OK:
		# TODO: Error handling!
		return {}
		
	var result = json.data
	if json.data is Array:
		result = { "values": json.data}

	return result
	

####################################################################################################
# Loads collection information. First from a remote collections export file, then from local
# files if available.
#
# TODO: Comment in code again after debugging!
####################################################################################################
func _load_collection_infos():
	_read_remote_collection_infos()

	var resourceFiles = DirAccess.get_files_at("res://")
	for resourceFile in resourceFiles:
		if resourceFile.ends_with(".artivact.collection.zip"):
			_merge_collection_info("res://", resourceFile)
	
	resourceFiles = DirAccess.get_files_at("user://")
	for resourceFile in resourceFiles:
		if resourceFile.ends_with(".artivact.collection.zip"):
			_merge_collection_info("user://", resourceFile)

	
####################################################################################################
# Reads downloaded collection information into the collection infos array:
####################################################################################################
func _read_remote_collection_infos():
	var zipReader = ZIPReader.new()
	var openResult := zipReader.open(contentExportOverviewsFile)
	if openResult != OK:
		# File might not have been downloaded by the user...
		return

	var contentExportOverviewsJson := JSON.new()
	var contentExportOverviewsJsonFile = zipReader.read_file("artivact.collection-export-overviews.json").get_string_from_utf8()
	var parseResult := contentExportOverviewsJson.parse(contentExportOverviewsJsonFile)
	if parseResult != OK:
		SignalBus.debug_json({"status": "ERROR", "file": "artivact.collection-export-overviews.json", "parseResult": parseResult})
		return

	var contentExportOverviews = contentExportOverviewsJson.data
	
	for rawContentExport in contentExportOverviews:
	
		var contentExport = ContentExport.new(rawContentExport)
		
		var collectionInfo = CollectionInfo.new(contentExport.id)
		collectionInfo.set_online_data(contentExport)
		
		for fileInZip in zipReader.get_files():
			if fileInZip.begins_with(contentExport.id):
				var img = zipReader.read_file(fileInZip)
				var coverPicture = Image.new()
				var loadResult = ERR_UNAVAILABLE
				if fileInZip.ends_with("jpg") || fileInZip.ends_with("JPG") || fileInZip.ends_with("jpeg") || fileInZip.ends_with("JPEG"):
					loadResult = coverPicture.load_jpg_from_buffer(img)
				elif fileInZip.ends_with("png") || fileInZip.ends_with("PNG"):
					loadResult = coverPicture.load_png_from_buffer(img)
				if loadResult == OK:
					collectionInfo.set_cover_picture(ImageTexture.create_from_image(coverPicture))
			
		collectionInfos.append(collectionInfo)
	

####################################################################################################
# Loads collection info from a local Artivact collection export file
####################################################################################################
func _merge_collection_info(locationPrefix: String, collectionFile: String):
	var collectionId = collectionFile.replace(".artivact.collection.zip", "")
	var collectionZipFile = str(locationPrefix, collectionFile)
	var collectionJsonFile = "artivact.content.json"
	var propertiesConfigurationJsonFile = "configs/properties.artivact.configuration.json"
	
	var zipReader = ZIPReader.new()
	var openResult := zipReader.open(collectionZipFile)
	if openResult != OK:
		SignalBus.debug_json({"status": "ERROR", "file": collectionZipFile, "openResult": openResult})
		DirAccess.remove_absolute(collectionZipFile)
		return

	# Store general collection information:
	var collectionJson := JSON.new()
	var collectionJsonString = zipReader.read_file(collectionJsonFile).get_string_from_utf8()
	var parseResult := collectionJson.parse(collectionJsonString)
	if parseResult != OK:
		SignalBus.debug_json({"status": "ERROR", "file": collectionJsonFile, "parseResult": parseResult})
		return
	var collectionData = collectionJson.data
	artivactContentJsons[collectionId] = ArtivactContentJson.new(collectionData)
	
	# Store the properties configuration of the collection:
	var propertiesJson := JSON.new()
	var propertiesJsonString = zipReader.read_file(propertiesConfigurationJsonFile).get_string_from_utf8()
	parseResult = propertiesJson.parse(propertiesJsonString)
	if parseResult != OK:
		SignalBus.debug_json({"status": "ERROR", "file": propertiesJsonString, "parseResult": parseResult})
		return
	var propertiesConfigurationData = propertiesJson.data
	artivactPropertiesConfigurationJsons[collectionId] = ArtivactPropertiesConfigurationJson.new(propertiesConfigurationData)
	
	# Store the ZIP reader for the collection file:
	collectionZipReaders[collectionId] = zipReader
	
	# Create collection info for the main menu:
	var lastModified = FileAccess.get_modified_time(collectionZipFile)
	var file := FileAccess.open(collectionZipFile, FileAccess.READ)
	var fileSize = file.get_length()
	
	var collectionInfo = CollectionInfo.new(collectionId)
	collectionInfo.set_local_data(artivactContentJsons[collectionId], lastModified, fileSize, collectionZipFile)
	
	# Create the cover picture if available:
	for fileInZip in zipReader.get_files():
		if fileInZip.begins_with("cover-picture"):
			var img = zipReader.read_file(fileInZip)
			var coverPicture = Image.new()
			var loadResult = ERR_UNAVAILABLE
			if fileInZip.ends_with("jpg") || fileInZip.ends_with("JPG") || fileInZip.ends_with("jpeg") || fileInZip.ends_with("JPEG"):
				loadResult = coverPicture.load_jpg_from_buffer(img)
			elif fileInZip.ends_with("png") || fileInZip.ends_with("PNG"):
				loadResult = coverPicture.load_png_from_buffer(img)
			if loadResult == OK:
				collectionInfo.set_cover_picture(ImageTexture.create_from_image(coverPicture))
	
	var remoteInfoFound = false
	for existingCollectionInfo in collectionInfos:
		if existingCollectionInfo.id == collectionInfo.id:
			existingCollectionInfo.set_local_data(artivactContentJsons[collectionId], lastModified, fileSize, collectionZipFile)
			remoteInfoFound = true
	
	if !remoteInfoFound:
		collectionInfos.append(collectionInfo)
