extends Control

var cardScene: Resource = load("res://scenes/main/ui/collection_card.tscn")

var initialized: bool = false


func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.MAIN_COLLECTION_INFOS_UPDATED, _collection_infos_updated)
	SignalBus.register(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION, _download_collection)
	SignalBus.register(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION_PROGRESS, _download_collection_progress)
	SignalBus.register(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION_FINISHED, _clear_operation_in_progress)


func _exit_tree():
	# Deregister signals:
	SignalBus.deregister(SignalBus.SignalType.MAIN_COLLECTION_INFOS_UPDATED, _collection_infos_updated)
	SignalBus.deregister(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION, _download_collection)
	SignalBus.deregister(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION_PROGRESS, _download_collection_progress)
	SignalBus.deregister(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION_FINISHED, _clear_operation_in_progress)


func _ready():
	if !initialized:
		initialized = true
		if CollectionStore.collectionInfos.size() > 0:
			_collection_infos_updated()


func _input(event):
	if event is InputEventMouseMotion:
		# Move our cursor
		var mouse_motion : InputEventMouseMotion = event
		$Cursor.position = mouse_motion.position - Vector2(20, 20)


func _collection_infos_updated() -> void:
	_clear_operation_in_progress()
	
	var content: Array[Object] = []
	var collectionInfos: Array[CollectionInfo] = CollectionStore.collectionInfos
	
	var fontSize = 96
	if collectionInfos.size() >= 9:
		$PaginationContainer.pageSize = 9
		$PaginationContainer.columns = 3
		fontSize = 32
	elif collectionInfos.size() >= 4:
		$PaginationContainer.pageSize = 4
		$PaginationContainer.columns = 2
		fontSize = 64
		
	for collectionInfo in collectionInfos:
		var cardSceneInstance = cardScene.instantiate()
		cardSceneInstance.initialize(collectionInfo, fontSize)
		content.push_back(cardSceneInstance)
		
	$PaginationContainer.set_content(content)


func _on_quit_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.MAIN_EXIT_APPLICATION)


func _download_collection(collectionId: String):
	find_child("StatusLabel").text = tr("MAIN_DOWNLOADING")
	find_child("OperationInProgressCover").visible = true


func _download_collection_progress(progress: int):
	find_child("StatusLabel").text = str(tr("MAIN_DOWNLOADING"), ' ', progress, '%')


func _clear_operation_in_progress():
	find_child("OperationInProgressCover").visible = false
	find_child("StatusLabel").text = ''
