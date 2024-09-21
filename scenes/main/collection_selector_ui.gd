extends Control


func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, update_collection_info)
	SignalBus.register(SignalBus.SignalType.UPDATE_REMOTE_COLLECTION_INFOS, _update_remote_collection_infos)
	SignalBus.register(SignalBus.SignalType.COLLECTION_INFOS_UPDATED, _clear_operation_in_progress)
	SignalBus.register(SignalBus.SignalType.RELOAD_COLLECTION_INFOS, _reload_collection_infos)
	SignalBus.register(SignalBus.SignalType.RELOAD_COLLECTION_INFOS_FINISHED, _clear_operation_in_progress)
	SignalBus.register(SignalBus.SignalType.DOWNLOAD_COLLECTION, _download_collection)
	SignalBus.register(SignalBus.SignalType.DOWNLOAD_COLLECTION_PROGRESS, _download_collection_progress)
	SignalBus.register(SignalBus.SignalType.DOWNLOAD_COLLECTION_FINISHED, _clear_operation_in_progress)


func _exit_tree():
	# Deregister signals:
	SignalBus.deregister(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, update_collection_info)
	SignalBus.deregister(SignalBus.SignalType.UPDATE_REMOTE_COLLECTION_INFOS, _update_remote_collection_infos)
	SignalBus.deregister(SignalBus.SignalType.COLLECTION_INFOS_UPDATED, _clear_operation_in_progress)
	SignalBus.deregister(SignalBus.SignalType.RELOAD_COLLECTION_INFOS, _reload_collection_infos)
	SignalBus.deregister(SignalBus.SignalType.RELOAD_COLLECTION_INFOS_FINISHED, _clear_operation_in_progress)
	SignalBus.deregister(SignalBus.SignalType.DOWNLOAD_COLLECTION, _download_collection)
	SignalBus.deregister(SignalBus.SignalType.DOWNLOAD_COLLECTION_PROGRESS, _download_collection_progress)
	SignalBus.deregister(SignalBus.SignalType.DOWNLOAD_COLLECTION_FINISHED, _clear_operation_in_progress)


func previous_collection_info():
	SignalBus.trigger(SignalBus.SignalType.PREVIOUS_COLLECTION_INFO)


func next_collection_info():
	SignalBus.trigger(SignalBus.SignalType.NEXT_COLLECTION_INFO)
	

func update_collection_info(collectionInfo: CollectionInfo, data: Dictionary):
	var titleLabel = find_child("TitleLabel")
	if titleLabel != null:
		titleLabel.text = collectionInfo.title

	var descriptionLabel = find_child("DescriptionLabel")
	if descriptionLabel != null:
		descriptionLabel.text = collectionInfo.description

	var fileSizeLabel = find_child("FileSizeLabel")
	if fileSizeLabel != null:
		fileSizeLabel.text = collectionInfo.get_formatted_filesize()
	
	var paginatorLabel = find_child("PaginatorLabel")
	if paginatorLabel != null:
		paginatorLabel.text = str(data["currentCollectionInfoIndex"] + 1, " / ", data["totalCollectionInfos"])
		
	var coverPictureTextureRect = find_child("CoverPictureTextureRect")
	if coverPictureTextureRect != null && collectionInfo.coverPicture != null:
		coverPictureTextureRect.texture = collectionInfo.coverPicture
	elif coverPictureTextureRect != null:
		coverPictureTextureRect.texture = null


func _update_remote_collection_infos():
	find_child("StatusLabel").text = tr("MAIN_SYNCHRONIZING")
	find_child("OperationInProgressCover").visible = true


func _download_collection():
	find_child("StatusLabel").text = tr("MAIN_DOWNLOADING")
	find_child("OperationInProgressCover").visible = true


func _download_collection_progress(progress: int):
	find_child("StatusLabel").text = str(tr("MAIN_DOWNLOADING"), ' ', progress, '%')


func _reload_collection_infos():
	var statusLabel = find_child("StatusLabel")
	if statusLabel != null:
		statusLabel.text = tr("MAIN_LOADING")
	var operationInProgressCover = find_child("OperationInProgressCover")
	if operationInProgressCover != null:
		operationInProgressCover.visible = true


func _clear_operation_in_progress(success: bool):
	find_child("OperationInProgressCover").visible = false
	find_child("StatusLabel").text = ''
