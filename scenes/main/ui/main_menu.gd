extends Control



func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, _update_collection_info)


func _exit_tree():
	# Deregister signals:
	SignalBus.deregister(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, _update_collection_info)


func _enter_tree():
	find_child("OpenButton").disabled = true
	find_child("DownloadButton").disabled = true
	find_child("DeleteButton").disabled = true


func _input(event):
	if event is InputEventMouseMotion:
		# Move our cursor
		var mouse_motion : InputEventMouseMotion = event
		$Cursor.position = mouse_motion.position - Vector2(20, 20)


func _update_collection_info(collectionInfo: CollectionInfo, data: Dictionary):
	var paginatorLabel = find_child("PaginatorLabel")
	if paginatorLabel != null:
		paginatorLabel.text = str(data["currentCollectionInfoIndex"] + 1, " / ", data["totalCollectionInfos"])
		
	var deleteButton = find_child("DeleteButton")
	deleteButton.disabled = true
	var downloadButton = find_child("DownloadButton")
	downloadButton.disabled = true
	var openButton = find_child("OpenButton")
	openButton.disabled = true
	
	var downloadButtonUpdateIndicator = find_child("DownloadButtonUpdateIndicator")
	downloadButtonUpdateIndicator.visible = false
	
	if collectionInfo.localFile != "":
		openButton.disabled = false
		deleteButton.disabled = !collectionInfo.can_be_deleted()

	if collectionInfo.localFile != "" && collectionInfo.update_available():
		downloadButton.disabled = false
		downloadButtonUpdateIndicator.visible = true
	elif collectionInfo.localFile == "" && collectionInfo.update_available():
		downloadButton.disabled = false
	else:
		downloadButton.disabled = true


func _on_exit_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.EXIT_APPLICATION)


func _on_synchronize_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.UPDATE_REMOTE_COLLECTION_INFOS)


func _on_settings_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.OPEN_SETTINGS)


func _on_download_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.DOWNLOAD_COLLECTION)


func _on_delete_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.DELETE_COLLECTION)


func _on_previous_collection_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.PREVIOUS_COLLECTION_INFO)


func _on_next_collection_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.NEXT_COLLECTION_INFO)


func _on_open_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.OPEN_COLLECTION)
