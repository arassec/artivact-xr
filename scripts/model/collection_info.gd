class_name CollectionInfo

extends Object

var id: String = ""
var title: String = ""
var description: String = ""
var lastModified: int = -1
var fileSize: int = -1
var localFile: String
var lastModifiedRemote: int = -1
var fileSizeRemote: int = -1
var coverPicture: ImageTexture

func _init(collectionId: String, artivactContentJson: ArtivactContentJson = null, lastModiefiedInput = -1, fileSizeInput = -1, localFileInput = ""):
	id = collectionId
	lastModified = lastModiefiedInput
	fileSize = fileSizeInput
	localFile = localFileInput
	
	if artivactContentJson != null:
		title = artivactContentJson.title.translate()
		description = artivactContentJson.description.translate()
	

func update_online_data(onlineData: ContentExport):
	if onlineData != null:
		title = onlineData.title.translate()
		description = onlineData.description.translate()
		fileSizeRemote = onlineData.size
		lastModifiedRemote = onlineData.lastModified


func set_cover_picture(coverPictureInput: ImageTexture):
	coverPicture = coverPictureInput
	

func get_formatted_filesize():
	if fileSize == -1 && fileSizeRemote == -1:
		return ""
		
	var sizeInput = fileSize
	if fileSize == -1:
		sizeInput = fileSizeRemote
	
	var unit = "GB"
	var size = (sizeInput * 1.0)/1024/1024/1024
	if size < 1:
		unit = "MB"
		size = (sizeInput * 1.0)/1024/1024
	return "Size: {0} {1}".format({0: "%0.2f" % size, 1: unit})


func update_available():
	return lastModified < (lastModifiedRemote / 1000)


func can_be_deleted():
	return localFile != null && localFile.begins_with("user://")
