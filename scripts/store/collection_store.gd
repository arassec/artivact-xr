extends Node

# Path to the file containing available content exports of the remote Artivact server:
var contentExportOverviewsFile = "user://artivact.content-export-overviews.zip"

# Contains basic collection information:
var collectionInfos: Array[CollectionInfo] = []
# The index of the currently selected collection info:
var currentCollectionInfoIndex: int = 0

# Contains the collection ZIP readers, indexed by the collection's ID.
#    Collection ID -> ZIP Reader of the collection's ZIP file on disk
var collectionZipReaders: Dictionary = {}

# Contains the parsed content export JSON file, indexed by the collection's ID.
#    Collection ID -> ArtivactContentJson
var artivactContentJsons: Dictionary = {}

var loadCollectionInfosThread: Thread


func _process(delta):
	if loadCollectionInfosThread != null:
		if loadCollectionInfosThread.is_started() && !loadCollectionInfosThread.is_alive():
			loadCollectionInfosThread.wait_to_finish()
			loadCollectionInfosThread = null
			trigger_collection_info_update()
			SignalBus.trigger_with_payload(SignalBus.SignalType.RELOAD_COLLECTION_INFOS_FINISHED, true)


func get_collection_info():
	if currentCollectionInfoIndex >= 0 && currentCollectionInfoIndex < collectionInfos.size():
		return collectionInfos[currentCollectionInfoIndex]
	return null


func get_collection_id():
	var collectionInfo = get_collection_info()
	if collectionInfo != null:
		return collectionInfo.id
		

func get_collection_zip_reader() -> ZIPReader:
	var collectionId = get_collection_id()
	if collectionZipReaders.has(collectionId):
		return collectionZipReaders[collectionId]
	return null
	

func get_artivact_content_json() -> ArtivactContentJson:
	var collectionId = get_collection_id()
	if artivactContentJsons.has(collectionId):
		return artivactContentJsons[collectionId]
	return null
	

####################################################################################################
# Switches to the next collection information.
####################################################################################################
func next_collection_info():
	if currentCollectionInfoIndex < (collectionInfos.size() -1):
		currentCollectionInfoIndex = currentCollectionInfoIndex + 1
		trigger_collection_info_update()


####################################################################################################
# Switches to the previous collection information.
####################################################################################################
func previous_collection_info():
	if currentCollectionInfoIndex > 0:
		currentCollectionInfoIndex = currentCollectionInfoIndex -1
		trigger_collection_info_update()


func trigger_collection_info_update():
	var collectionInfo = get_collection_info()
	if collectionInfo != null:
		SignalBus.trigger_with_multiload(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, collectionInfo, {"currentCollectionInfoIndex": currentCollectionInfoIndex, "totalCollectionInfos": collectionInfos.size()})



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
	SignalBus.trigger(SignalBus.SignalType.RELOAD_COLLECTION_INFOS)
	collectionInfos.clear()
	loadCollectionInfosThread = Thread.new()
	loadCollectionInfosThread.start(_load_collection_infos)




####################################################################################################
# TODO
####################################################################################################
func read_json_file(jsonFile: String) -> Dictionary:
	var json := JSON.new()
	var jsonString = get_collection_zip_reader().read_file(jsonFile).get_string_from_utf8()
	var parseResult := json.parse(jsonString)
	
	if parseResult != OK:
		# TODO: Error handling!
		return {}
		
	var result = json.data
	if json.data is Array:
		result = { "values": json.data}

	return result
	

####################################################################################################
# Loads collection information. First from local content export files found in the filesystem, and 
# afterwards from the downloaded remote file with information about available collections, if it 
# exists.
####################################################################################################
func _load_collection_infos():
	var resourceFiles = DirAccess.get_files_at("res://")
	for resourceFile in resourceFiles:
		if resourceFile.ends_with(".artivact.content.json.zip"):
			_load_collection_info("res://", resourceFile)
	
	resourceFiles = DirAccess.get_files_at("user://")
	for resourceFile in resourceFiles:
		if resourceFile.ends_with(".artivact.content.json.zip"):
			_load_collection_info("user://", resourceFile)
	
	_merge_remote_collection_infos()

	if currentCollectionInfoIndex >= collectionInfos.size():
		currentCollectionInfoIndex = 0
	

####################################################################################################
# Loads collection info from a local Artivact content export file
####################################################################################################
func _load_collection_info(locationPrefix: String, collectionFile: String):
	var collectionId = collectionFile.replace(".artivact.content.json.zip", "")
	var collectionZipFile = str(locationPrefix, collectionFile)
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
	
	var collectionInfo = CollectionInfo.new(collectionId, artivactContentJsons[collectionId], lastModified, fileSize, collectionZipFile)

	# Create the cover picture if available:
	for fileInZip in zipReader.get_files():
		if fileInZip.begins_with(collectionId) && !fileInZip.ends_with(".artivact.menu.json"):
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
# Merges downloaded collection information into the already created collection infos from the local
# filesystem:
####################################################################################################
func _merge_remote_collection_infos():
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
