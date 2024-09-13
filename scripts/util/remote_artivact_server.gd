class_name RemoteArtivactServer

extends Node

var apiUrl: String = "https://www.arassec.com/api"

var thread: Thread


func get_collection_infos(callback: Callable, targetFile: String):
	$HTTPRequest.request_completed.connect(callback)
	$HTTPRequest.set_download_file(targetFile)
	$HTTPRequest.request(str(apiUrl, "/export/content/overview"))


func download_collection(callback: Callable, collectionId: String):
	$HTTPRequest.request_completed.connect(callback)
	$HTTPRequest.set_download_file(str("user://", collectionId, ".artivact.content.json.zip"))
	$HTTPRequest.use_threads = true
	$HTTPRequest.request(str(apiUrl, "/export/content/", collectionId, "/JSON"))


func get_progress(totalSize):
	var progress = $HTTPRequest.get_downloaded_bytes()
	if progress == 0:
		return 0
	return ((progress * 1.0) / totalSize) * 100
