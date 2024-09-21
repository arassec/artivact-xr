extends Node


var widget

var itemIds: Array[String] = []

#   itemId -> ArtivactItem
var items: Dictionary = {}

var currentItemId = null
var currentItemIndex

var initialized = false
var modelLoaded = false

var modelLoaderThread: Thread
var loadedModel: Node

var rotateModel = true


func initialize(widgetInput: ItemSearchWidget):
	widget = widgetInput
	var json = CollectionStore.read_json_file(str(widget.id, ".artivact.search-result.json"))

	for itemId in json.values:
		itemIds.append(itemId)

	if itemIds.size() > 0:
		currentItemIndex = 0
		currentItemId = itemIds[currentItemIndex]
		items[currentItemId] = ArtivactItem.new(CollectionStore.read_json_file(str(currentItemId, "/", currentItemId, ".artivact.item.json")))


func _ready():
	_get_previous_button().pressed.connect(self._change_model.bind(false))
	_get_next_button().pressed.connect(self._change_model.bind(true))
	_get_rotate_button().pressed.connect(self._toggle_rotate)
	_get_info_button().pressed.connect(self._toggle_info)
	_update_paginator_label()
	_toggle_info()
	

func _input(event):
	if event is InputEventKey && !event.pressed && event.keycode == Key.KEY_LEFT:
		_change_model(false)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_RIGHT:
		_change_model(true)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_R:
		_toggle_rotate()
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_I:
		_toggle_info()


func _process(delta):
	if !initialized && currentItemId != null:
		initialized = true
		currentItemIndex = -1
		_change_model(true)
	
	if modelLoaded:
		modelLoaded = false
		_update_info()
		$ModelAnchor.add_child(loadedModel)
		var itemTitleLabel = find_child("ItemTitleLabel")
		itemTitleLabel.text = items[currentItemId].title.translate()
		_enable_buttons()
	
	if loadedModel != null && rotateModel:
		loadedModel.rotate(Vector3(0, 1, 0), 0.4 * delta)


func _change_model(forward: bool):
	_disable_buttons()
	
	var infoScene = _get_info_scene()
	if infoScene.visible:
		_toggle_info()	
	
	if forward:
		currentItemIndex = currentItemIndex + 1
	else:
		currentItemIndex = currentItemIndex -1
		
	if currentItemIndex >= itemIds.size():
		currentItemIndex = 0
	elif currentItemIndex < 0:
		currentItemIndex = itemIds.size() - 1
		
	currentItemId = itemIds[currentItemIndex]
	
	if loadedModel != null:
		$ModelAnchor.remove_child(loadedModel)
		loadedModel.queue_free()
	
	_update_paginator_label()
	
	if modelLoaderThread != null && modelLoaderThread.is_started():
		modelLoaderThread.wait_to_finish()

	modelLoaderThread = Thread.new()
	modelLoaderThread.start(_load_model.bind(currentItemId), Thread.PRIORITY_LOW)


func _toggle_rotate():
	rotateModel = !rotateModel


func _toggle_info():
	var uiScene = _get_info_scene()
	uiScene.visible = !uiScene.visible
	if loadedModel != null:
		loadedModel.visible = !uiScene.visible


func _update_info():
	var uiScene = _get_info_scene()
	uiScene.update(items[currentItemId])


func _get_info_scene():
	var uiVieport = $ItemInfoUiViewport2Din3D
	var uiScene = uiVieport.get_scene_instance()
	return uiScene


func _load_model(itemId: String):
	if !items.has(itemId):
		items[itemId] = ArtivactItem.new(CollectionStore.read_json_file(str(itemId, "/", itemId, ".artivact.item.json")))

	var gltfDocument = GLTFDocument.new()
	var gltfState = GLTFState.new()

	var zipReader = CollectionStore.get_collection_zip_reader()
	# TODO: Model selection / Model array handling
	var model = items[currentItemId].models[0]
	var modelFile = str(itemId, "/", model)
	var modelData = zipReader.read_file(modelFile)
	var result = gltfDocument.append_from_buffer(modelData, "", gltfState, 64)

	if result != OK:
		var errMsg = str("widgets.item_search.load_model(", itemId, " / ", model, "): FAILED - ", result)
		printerr(errMsg)
		return

	loadedModel = gltfDocument.generate_scene(gltfState)
	
	ModelHelper.scale_model(loadedModel, 2, 100)

	modelLoaded = true


func _get_previous_button() -> Button:
	var uiVieport = $ItemSearchUiViewport2Din3D
	var uiScene = uiVieport.get_scene_instance()
	return uiScene.find_child("PreviousButton")


func _get_next_button() -> Button:
	var uiVieport = $ItemSearchUiViewport2Din3D
	var uiScene = uiVieport.get_scene_instance()
	return uiScene.find_child("NextButton")


func _get_info_button() -> Button:
	var uiVieport = $ItemSearchUiViewport2Din3D
	var uiScene = uiVieport.get_scene_instance()
	return uiScene.find_child("InfoButton")


func _get_rotate_button() -> Button:
	var uiVieport = $ItemSearchUiViewport2Din3D
	var uiScene = uiVieport.get_scene_instance()
	return uiScene.find_child("RotateButton")


func _disable_buttons():
	_get_previous_button().disabled = true
	_get_next_button().disabled = true
	_get_info_button().disabled = true
	_get_rotate_button().disabled = true


func _enable_buttons():
	_get_previous_button().disabled = false
	_get_next_button().disabled = false
	_get_info_button().disabled = false
	_get_rotate_button().disabled = false


func _update_paginator_label():
	var uiVieport = $ItemSearchUiViewport2Din3D
	var uiScene = uiVieport.get_scene_instance()
	var paginatorLabel = uiScene.find_child("PaginatorLabel")
	paginatorLabel.text = str(currentItemIndex + 1, " / ", itemIds.size())
