extends Node



func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, update_collection_info)


func _exit_tree():
	# Deregister signals:
	SignalBus.deregister(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, update_collection_info)


func _enter_tree():
	find_child("DownloadButton").disabled = true
	find_child("DeleteButton").disabled = true


func update_collection_info(collectionInfo: CollectionInfo, data: Dictionary):
	if collectionInfo.localFile:
		find_child("DeleteButton").disabled = false
	else:
		find_child("DeleteButton").disabled = true

	# TODO: I18N
	var downloadButton = find_child("DownloadButton")
	if collectionInfo.localFile != "" && collectionInfo.update_available():
		downloadButton.text = "Update"
		downloadButton.disabled = false
	elif collectionInfo.localFile == "" && collectionInfo.update_available():
		downloadButton.text = "Download"
		downloadButton.disabled = false
	else:
		downloadButton.text = "Download"
		downloadButton.disabled = true


func open_collection():
	SignalBus.trigger(SignalBus.SignalType.OPEN_COLLECTION)


func download_collection():
	SignalBus.trigger(SignalBus.SignalType.DOWNLOAD_COLLECTION)
	

func delete_collection():
	SignalBus.trigger(SignalBus.SignalType.OPEN_COLLECTION)
