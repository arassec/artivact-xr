class_name RemoteArtivactServer

extends Node


var thread: Thread


func get_collection_infos(callback: Callable, targetFile: String):
	$HTTPRequest.request_completed.connect(callback)
	$HTTPRequest.set_download_file(targetFile)
	$HTTPRequest.request(str(SettingsStore.get_value(SettingsStore.SettingType.API_URL), "/collection/export/info"))


func download_collection(callback: Callable, collectionId: String):
	$HTTPRequest.request_completed.connect(callback)
	$HTTPRequest.set_download_file(str("user://", collectionId, ".artivact.collection.zip"))
	$HTTPRequest.use_threads = true
	$HTTPRequest.request(str(SettingsStore.get_value(SettingsStore.SettingType.API_URL), "/collection/export/", collectionId, "/file"))


func get_progress(totalSize):
	var progress = $HTTPRequest.get_downloaded_bytes()
	if progress == 0:
		return 0
	return ((progress * 1.0) / totalSize) * 100
