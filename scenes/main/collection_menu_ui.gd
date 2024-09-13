extends Node



func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, update_collection_info)


func _exit_tree():
	# Deregister signals:
	SignalBus.deregister(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, update_collection_info)


func _enter_tree():
	find_child("OpenButton").disabled = true
	find_child("DownloadButton").disabled = true
	find_child("DeleteButton").disabled = true


func update_collection_info(collectionInfo: CollectionInfo, data: Dictionary):
	if collectionInfo.localFile != "":
		find_child("OpenButton").disabled = false
		find_child("DeleteButton").disabled = !collectionInfo.can_be_deleted()
	else:
		find_child("OpenButton").disabled = true
		find_child("DeleteButton").disabled = true

	var downloadButton = find_child("DownloadButton")
	if collectionInfo.localFile != "" && collectionInfo.update_available():
		downloadButton.text = tr("MAIN_UPDATE")
		downloadButton.disabled = false
	elif collectionInfo.localFile == "" && collectionInfo.update_available():
		downloadButton.text = tr("MAIN_DOWNLOAD")
		downloadButton.disabled = false
	else:
		downloadButton.text = tr("MAIN_UPTODATE")
		downloadButton.disabled = true


func open_collection():
	SignalBus.trigger(SignalBus.SignalType.OPEN_COLLECTION)


func download_collection():
	SignalBus.trigger(SignalBus.SignalType.DOWNLOAD_COLLECTION)
	

func delete_collection():
	SignalBus.trigger(SignalBus.SignalType.DELETE_COLLECTION)
