extends Node


var widget

var itemIds: Array[String] = []

#   itemId -> ArtivactItem
var items: Dictionary = {}

var currentItemId = null
var currentItemIndex

var initialized = false
var loadingDone = false

var loaderThread: Thread
var loadedModel: Node
var loadedTexture: ImageTexture

var rotateModelHorizontally = true
var rotateModelVertically = false


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
	_get_previous_button().pressed.connect(self._change_item.bind(false))
	_get_next_button().pressed.connect(self._change_item.bind(true))
	_get_rotate_horizontally_button().pressed.connect(self._toggle_rotate_horizontally)
	_get_rotate_vertically_button().pressed.connect(self._toggle_rotate_vertically)
	_get_info_button().pressed.connect(self._toggle_info)
	_get_data_button().pressed.connect(self._toggle_data)
	_update_paginator_label()
	_update_info()
	_toggle_info()
	$ImageAnchor.visible = false
	

func _input(event):
	if loaderThread != null && loaderThread.is_alive():
		return
	if event is InputEventKey && !event.pressed && event.keycode == Key.KEY_LEFT:
		_change_item(false)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_RIGHT:
		_change_item(true)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_H:
		_toggle_rotate_horizontally()
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_V:
		_toggle_rotate_vertically()
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_I:
		_toggle_info()
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_D:
		_toggle_data()


func _process(delta):
	if !initialized && currentItemId != null:
		initialized = true
		currentItemIndex = -1
		_change_item(true)
	
	if loadingDone:
		loadingDone = false
		loaderThread.wait_to_finish()
		loaderThread = null
		_update_data()
		var itemTitleLabel = find_child("ItemTitleLabel")
		itemTitleLabel.text = items[currentItemId].title.translate()
		_enable_buttons()
		if loadedModel != null:
			$ModelAnchor.add_child(loadedModel)
		elif loadedTexture != null:
			$ImageAnchor.mesh.material.albedo_texture = loadedTexture  
			$ImageAnchor.visible = true
	
	if loadedModel != null && rotateModelHorizontally:
		loadedModel.rotate(Vector3(0, 1, 0), 0.4 * delta)
	elif loadedModel != null && rotateModelVertically:
		loadedModel.rotate(Vector3(1, 0, 0), 0.4 * delta)


func _change_item(forward: bool):
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
		
	if loadedTexture != null:
		$ImageAnchor.mesh.material.albedo_texture = null
		$ImageAnchor.visible = false
	
	_update_paginator_label()
	
	if loaderThread != null && loaderThread.is_started():
		loaderThread.wait_to_finish()

	loaderThread = Thread.new()
	loaderThread.start(_load_item.bind(currentItemId), Thread.PRIORITY_LOW)


func _toggle_rotate_horizontally():
	rotateModelVertically = false
	rotateModelHorizontally = !rotateModelHorizontally


func _toggle_rotate_vertically():
	rotateModelHorizontally = false
	rotateModelVertically = !rotateModelVertically


func _toggle_info():
	var infoScene = _get_info_scene()
	infoScene.visible = !infoScene.visible
	var dataScene = _get_data_scene()
	dataScene.visible = false
	if loadedModel != null:
		loadedModel.visible = !infoScene.visible


func _toggle_data():
	var dataScene = _get_data_scene()
	dataScene.visible = !dataScene.visible
	var infoScene = _get_info_scene()
	infoScene.visible = false
	if loadedModel != null:
		loadedModel.visible = !dataScene.visible


func _update_info():
	var uiScene = _get_info_scene()
	uiScene.update(widget)


func _update_data():
	var uiScene = _get_data_scene()
	uiScene.update(items[currentItemId])


func _get_info_scene():
	var uiVieport = $ItemInfoUiViewport2Din3D
	var uiScene = uiVieport.get_scene_instance()
	return uiScene


func _get_data_scene():
	var uiVieport = $ItemDataUiViewport2Din3D
	var uiScene = uiVieport.get_scene_instance()
	return uiScene


func _load_item(itemId: String):
	if !items.has(itemId):
		items[itemId] = ArtivactItem.new(CollectionStore.read_json_file(str(itemId, "/", itemId, ".artivact.item.json")))

	if items[currentItemId].models.size() > 0:
		_load_model(currentItemId)
	elif items[currentItemId].images.size() > 0:
		_load_image(currentItemId)
	else:
		loadingDone = true



func _load_model(itemId: String):
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

	loadingDone = true


func _load_image(itemId: String):
	var imageFile = items[currentItemId].images[0]
	var img = CollectionStore.get_collection_zip_reader().read_file(str(itemId, "/", imageFile))
	
	var image = Image.new()
	var loadResult = ERR_UNAVAILABLE
	if imageFile.ends_with("jpg") || imageFile.ends_with("JPG") || imageFile.ends_with("jpeg") || imageFile.ends_with("JPEG"):
		loadResult = image.load_jpg_from_buffer(img)
	elif imageFile.ends_with("png") || imageFile.ends_with("PNG"):
		loadResult = image.load_png_from_buffer(img)

	if loadResult == OK:
		loadedTexture = ImageTexture.create_from_image(image)

	loadingDone = true


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


func _get_data_button() -> Button:
	var uiVieport = $ItemSearchUiViewport2Din3D
	var uiScene = uiVieport.get_scene_instance()
	return uiScene.find_child("DataButton")


func _get_rotate_horizontally_button() -> Button:
	var uiVieport = $ItemSearchUiViewport2Din3D
	var uiScene = uiVieport.get_scene_instance()
	return uiScene.find_child("RotateHButton")


func _get_rotate_vertically_button() -> Button:
	var uiVieport = $ItemSearchUiViewport2Din3D
	var uiScene = uiVieport.get_scene_instance()
	return uiScene.find_child("RotateVButton")


func _disable_buttons():
	_get_previous_button().disabled = true
	_get_next_button().disabled = true
	_get_info_button().disabled = true
	_get_data_button().disabled = true
	_get_rotate_horizontally_button().disabled = true


func _enable_buttons():
	_get_previous_button().disabled = false
	_get_next_button().disabled = false
	_get_info_button().disabled = false
	_get_data_button().disabled = false
	_get_rotate_horizontally_button().disabled = false


func _update_paginator_label():
	var uiVieport = $ItemSearchUiViewport2Din3D
	var uiScene = uiVieport.get_scene_instance()
	var paginatorLabel = uiScene.find_child("PaginatorLabel")
	paginatorLabel.text = str(currentItemIndex + 1, " / ", itemIds.size())
