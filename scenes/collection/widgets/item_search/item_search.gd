extends Node


var widget

var itemIds: Array[String] = []

#   itemId -> ArtivactItem
var items: Dictionary = {}

var currentItemId = null
var currentItemIndex

var initialized = false


var uiScene

var loadedModel


func initialize(widgetInput: ItemSearchWidget):
	widget = widgetInput
	var json = CollectionStore.read_json_file(str(widget.id, ".artivact.search-result.json"))

	for itemId in json.values:
		itemIds.append(itemId)
		items[itemId] = ArtivactItem.new(CollectionStore.read_json_file(str(itemId, "/", itemId, ".artivact.item.json")))

	if itemIds.size() > 0:
		currentItemIndex = 0
		currentItemId = itemIds[currentItemIndex]


func _ready():
	var uiVieport = $ItemSearchUiViewport2Din3D
	uiScene = uiVieport.get_scene_instance()
	if uiScene != null:
		var previousButton = uiScene.find_child("PreviousButton")
		if previousButton != null:
			previousButton.pressed.connect(self._change_model.bind(false))
		var nextButton = uiScene.find_child("NextButton")
		if nextButton != null:
			nextButton.pressed.connect(self._change_model.bind(true))
		var paginatorLabel = uiScene.find_child("PaginatorLabel")
		if paginatorLabel != null:
			paginatorLabel.text = str(currentItemIndex + 1, " / ", items.size())
	var itemTitleLabel = find_child("ItemTitleLabel")
	itemTitleLabel.text = items[currentItemId].title.translate()
	

func _input(event):
	if event is InputEventKey && !event.pressed && event.keycode == Key.KEY_LEFT:
		_change_model(false)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_RIGHT:
		_change_model(true)



func _process(delta):
	if !initialized && currentItemId != null:
		_load_model(currentItemId)
		initialized = true
		
	loadedModel.rotate(Vector3(0, 1, 0), 0.4 * delta)


func _change_model(forward: bool):
	if forward:
		currentItemIndex = currentItemIndex + 1
	else:
		currentItemIndex = currentItemIndex -1
		
	if currentItemIndex >= items.size():
		currentItemIndex = 0
	elif currentItemIndex < 0:
		currentItemIndex = items.size() - 1
		
	currentItemId = itemIds[currentItemIndex]
	
	if loadedModel != null:
		$ModelAnchor.remove_child(loadedModel)
		loadedModel.queue_free()
	
	var paginatorLabel = uiScene.find_child("PaginatorLabel")
	if paginatorLabel != null:
		paginatorLabel.text = str(currentItemIndex + 1, " / ", items.size())
	
	var itemTitleLabel = find_child("ItemTitleLabel")
	itemTitleLabel.text = items[currentItemId].title.translate()
	
	_load_model(currentItemId)


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
	
	var size:Vector3
	for n in loadedModel.get_children().size():
		if "MeshInstance3D"	== loadedModel.get_child(n).get_class():
			var mesh:MeshInstance3D = loadedModel.get_child(n)
			size = mesh.get_aabb().size
			break;
	var targetSizeInM = 150 / 100.0 # Size should initially be 150cm.
	var currentSizeInM = size.x
	var scaleFactor = targetSizeInM / currentSizeInM
	loadedModel.scale = Vector3(scaleFactor, scaleFactor, scaleFactor)

	$ModelAnchor.add_child(loadedModel)
