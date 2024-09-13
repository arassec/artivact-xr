extends Node


var widget

var itemIds: Array[String] = []

#   itemId -> ArtivactItem
var items: Dictionary = {}

var currentItemId = null
var currentItemIndex

var initialized = false

func initialize(widgetInput: ItemSearchWidget):
	widget = widgetInput
	var json = CollectionStore.read_json_file(str(widget.id, ".artivact.search-result.json"))

	for itemId in json.values:
		itemIds.append(itemId)
		items[itemId] = ArtivactItem.new(CollectionStore.read_json_file(str(itemId, "/", itemId, ".artivact.item.json")))

	if itemIds.size() > 0:
		currentItemIndex = 0
		currentItemId = itemIds[currentItemIndex]



func _process(_delta):
	if !initialized && currentItemId != null:
		load_model(currentItemId)
		initialized = true



func load_model(itemId: String):
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

	var loadedModel = gltfDocument.generate_scene(gltfState)
	
	var size:Vector3
	for n in loadedModel.get_children().size():
		if "MeshInstance3D"	== loadedModel.get_child(n).get_class():
			var mesh:MeshInstance3D = loadedModel.get_child(n)
			size = mesh.get_aabb().size
			break;
	var targetSizeInM = 50 / 100.0 # Size should initially be 50cm.
	var currentSizeInM = size.x
	var scaleFactor = targetSizeInM / currentSizeInM
	loadedModel.scale = Vector3(scaleFactor, scaleFactor, scaleFactor)

	$Test.add_child(loadedModel)
