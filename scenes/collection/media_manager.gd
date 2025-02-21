extends Node3D


var mediaLoaderThread: Thread

var mediaModelNode: Node3D
var mediaImageTexture: ImageTexture
var mediaLoaded = false

var rotateModelHorizontally = true

var wasGripped = false


####################################################################################################
# Registers for signals.
####################################################################################################
func _init():
	SignalBus.register(SignalBus.SignalType.COLL_OPEN_ITEM_MEDIA, _open_item_media)
	SignalBus.register(SignalBus.SignalType.COLL_CLOSE_ITEM_MEDIA, _close_item_media)
	SignalBus.register(SignalBus.SignalType.CTRL_GRIP_PRESSED, _grab_item_model)
	SignalBus.register(SignalBus.SignalType.CTRL_GRIP_RELEASED, _release_item_model)


####################################################################################################
# Deregisters from signals.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.COLL_OPEN_ITEM_MEDIA, _open_item_media)
	SignalBus.deregister(SignalBus.SignalType.COLL_CLOSE_ITEM_MEDIA, _close_item_media)
	SignalBus.deregister(SignalBus.SignalType.CTRL_GRIP_PRESSED, _grab_item_model)
	SignalBus.deregister(SignalBus.SignalType.CTRL_GRIP_RELEASED, _release_item_model)


func _process(delta):
	if mediaLoaded:
		mediaLoaded = false
		if mediaLoaderThread:
			mediaLoaderThread.wait_to_finish()
			mediaLoaderThread = null

		if mediaModelNode:
			add_child(mediaModelNode)
		elif mediaImageTexture != null:
			$ImageAnchor.mesh.material.albedo_texture = mediaImageTexture  
			$ImageAnchor.visible = true

	if mediaModelNode != null && rotateModelHorizontally:
		mediaModelNode.rotate(Vector3(0, 1, 0), 0.4 * delta)


func _grab_item_model(controller: XRController3D) -> void:
	if controller != null && mediaModelNode != null && !mediaLoaded:
		wasGripped = true
		controller.find_child("FunctionPointer").visible = false
		rotateModelHorizontally = false
		remove_child(mediaModelNode)
		mediaModelNode.scale *= 0.25
		controller.add_child(mediaModelNode)


func _release_item_model(controller: XRController3D) -> void:
	if controller != null && mediaModelNode != null && wasGripped:
		wasGripped = false
		controller.find_child("FunctionPointer").visible = true
		controller.remove_child(mediaModelNode)
		mediaModelNode.scale *= 4
		add_child(mediaModelNode)
		rotateModelHorizontally = true


func _close_item_media() -> void:
	if mediaModelNode != null:
		remove_child(mediaModelNode)
		mediaModelNode.queue_free()
		mediaModelNode = null
	if mediaImageTexture != null:
		$ImageAnchor.mesh.material.albedo_texture = null
		$ImageAnchor.visible = false


func _open_item_media(item: ArtivactItem) -> void:
	_close_item_media()
	mediaLoaderThread = Thread.new()
	mediaLoaderThread.start(_load_media.bind(item), Thread.PRIORITY_LOW)


func _load_media(item: ArtivactItem) -> void:
	# TODO: Model and image pagination!
	if item && item.models.size() > 0:
		_load_model(item.id, item.models[0])
	elif item && item.images.size() > 0:
		_load_image(item.id, item.images[0])
	else:
		mediaLoaded = true


func _load_model(itemId: String, model: String):
	var gltfDocument = GLTFDocument.new()
	var gltfState = GLTFState.new()

	var zipReader = CollectionStore.get_collection_zip_reader(CollectionStore.get_selected_collection())
	var modelFile = str(itemId, "/", model)
	var modelData = zipReader.read_file(modelFile)
	var result = gltfDocument.append_from_buffer(modelData, "", gltfState, 64)

	if result != OK:
		var errMsg = str("widgets.item_search.load_model(", itemId, " / ", model, "): FAILED - ", result)
		printerr(errMsg)
		return

	mediaModelNode = gltfDocument.generate_scene(gltfState)
	
	ModelHelper.scale_model(mediaModelNode, 1.0)

	mediaLoaded = true


func _load_image(itemId: String, imageFile: String):
	var img = CollectionStore.get_collection_zip_reader(CollectionStore.get_selected_collection()).read_file(str(itemId, "/", imageFile))
	
	var image = Image.new()
	var loadResult = ERR_UNAVAILABLE
	if imageFile.ends_with("jpg") || imageFile.ends_with("JPG") || imageFile.ends_with("jpeg") || imageFile.ends_with("JPEG"):
		loadResult = image.load_jpg_from_buffer(img)
	elif imageFile.ends_with("png") || imageFile.ends_with("PNG"):
		loadResult = image.load_png_from_buffer(img)

	if loadResult == OK:
		mediaImageTexture = ImageTexture.create_from_image(image)

	mediaLoaded = true
