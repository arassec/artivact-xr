extends Node


var widget

var itemIds: Array[String] = []
var itemLabels: Array[String] = []

# itemId -> ArtivactItem
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
		items[itemId] = ArtivactItem.new(CollectionStore.read_json_file(str(itemId, "/", "artivact.item.json")))
		itemLabels.push_back(items[itemId].title.translate())

	if itemIds.size() > 0:
		currentItemIndex = 0
		currentItemId = itemIds[currentItemIndex]


func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.COLL_ITEM_NEXT, _change_item.bind(true))
	SignalBus.register(SignalBus.SignalType.COLL_ITEM_PREVIOUS, _change_item.bind(false))


func _exit_tree():
	# Deregister signals:
	SignalBus.deregister(SignalBus.SignalType.COLL_ITEM_NEXT, _change_item.bind(true))
	SignalBus.deregister(SignalBus.SignalType.COLL_ITEM_PREVIOUS, _change_item.bind(false))


func _ready():
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_ITEM_UPDATE_PAGINATOR, itemLabels)
	$ImageAnchor.visible = false


func _input(event):
	if loaderThread != null && loaderThread.is_alive():
		return
	if event is InputEventKey && !event.pressed && event.keycode == Key.KEY_LEFT:
		_change_item(false)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_RIGHT:
		_change_item(true)


func _process(delta):
	if !initialized && currentItemId != null:
		initialized = true
		currentItemIndex = -1
		_change_item(true)
	
	if loadingDone:
		SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_ITEM_UPDATE_DATA, items[currentItemId])
		loadingDone = false
		loaderThread.wait_to_finish()
		loaderThread = null
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

	if loaderThread != null && loaderThread.is_started():
		loaderThread.wait_to_finish()

	loaderThread = Thread.new()
	loaderThread.start(_load_item.bind(currentItemId), Thread.PRIORITY_LOW)


func _load_item(itemId: String):
	if items[currentItemId].models.size() > 0:
		_load_model(currentItemId)
	elif items[currentItemId].images.size() > 0:
		_load_image(currentItemId)
	else:
		loadingDone = true


func _load_model(itemId: String):
	var gltfDocument = GLTFDocument.new()
	var gltfState = GLTFState.new()

	var zipReader = CollectionStore.get_collection_zip_reader(CollectionStore.get_selected_collection())
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
	
	ModelHelper.scale_model(loadedModel, 1.5)

	loadingDone = true


func _load_image(itemId: String):
	var imageFile = items[currentItemId].images[0]
	var img = CollectionStore.get_collection_zip_reader(CollectionStore.get_selected_collection()).read_file(str(itemId, "/", imageFile))
	
	var image = Image.new()
	var loadResult = ERR_UNAVAILABLE
	if imageFile.ends_with("jpg") || imageFile.ends_with("JPG") || imageFile.ends_with("jpeg") || imageFile.ends_with("JPEG"):
		loadResult = image.load_jpg_from_buffer(img)
	elif imageFile.ends_with("png") || imageFile.ends_with("PNG"):
		loadResult = image.load_png_from_buffer(img)

	if loadResult == OK:
		loadedTexture = ImageTexture.create_from_image(image)

	loadingDone = true
