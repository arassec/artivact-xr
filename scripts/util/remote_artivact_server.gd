class_name RemoteArtivactServer

extends Node

var apiUrl: String = "https://www.arassec.com/api"


func get_collection_infos(callback: Callable, targetFile: String):
	$HTTPRequest.request_completed.connect(callback)
	$HTTPRequest.set_download_file(targetFile)
	$HTTPRequest.request(str(apiUrl, "/export/content/overview"))
