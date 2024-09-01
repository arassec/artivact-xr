extends Control


func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, update_collection_info)


func _exit_tree():
	# Deregister signals:
	SignalBus.deregister(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, update_collection_info)


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
		paginatorLabel.text = str(data["currentCollectionInfo"] + 1, " / ", data["totalCollectionInfos"])
		
	var coverPictureTextureRect = find_child("CoverPictureTextureRect")
	if coverPictureTextureRect != null && collectionInfo.coverPicture != null:
		coverPictureTextureRect.texture = collectionInfo.coverPicture
	elif coverPictureTextureRect != null:
		coverPictureTextureRect.texture = null
