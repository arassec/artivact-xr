class_name CollectionInfo

extends Object

var id: String = ""
var title: String = ""
var description: String = ""
var lastModified: int = -1
var fileSize: int = -1


func _init(collectionId: String, artivactContentJson: ArtivactContentJson, lastModiefiedInput: int, fileSizeInput: int):
	id = collectionId
	lastModified = lastModiefiedInput
	fileSize = fileSizeInput
	
	if artivactContentJson != null:
		title = artivactContentJson.title.translate()
		description = artivactContentJson.description.translate()
	

func updateOnlineData(onlineData: Dictionary):
	pass


func getFormattedFileSize():
	var unit = "GB"
	var size = (fileSize * 1.0)/1024/1024/1024
	if size < 1:
		unit = "MB"
		size = (fileSize * 1.0)/1024/1024
	return "{0} {1}".format({0: "%0.2f" % size, 1: unit})
