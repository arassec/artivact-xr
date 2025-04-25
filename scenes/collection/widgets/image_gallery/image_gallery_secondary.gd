extends Control


var widget: ImageGalleryWidget

var paginationContent: Array[Object] = []


func initialize(widgetInput: ImageGalleryWidget):
	if widgetInput == null:
		return
		
	widget = widgetInput
	
	_load_images()

	var paginationContainer = find_child("PaginationContainer")
	if paginationContainer && paginationContent.size() > 0:
		paginationContainer.set_content(paginationContent)
	

####################################################################################################
# Move the cursor on input events.
####################################################################################################
func _input(event):
	if event is InputEventMouseMotion:
		# Move our cursor
		var mouse_motion : InputEventMouseMotion = event
		$Cursor.position = mouse_motion.position - Vector2(20, 20)


func _load_images():
	
	# Load avatar image if available:
	for imageFile in widget.images:
		var img = CollectionStore.get_collection_zip_reader(CollectionStore.get_selected_collection()).read_file(str(widget.id, "/", imageFile))
	
		var image = Image.new()
		var loadResult = ERR_UNAVAILABLE
		if imageFile.ends_with("jpg") || imageFile.ends_with("JPG") || imageFile.ends_with("jpeg") || imageFile.ends_with("JPEG"):
			loadResult = image.load_jpg_from_buffer(img)
		elif imageFile.ends_with("png") || imageFile.ends_with("PNG"):
			loadResult = image.load_png_from_buffer(img)

		var imageTexture: ImageTexture = null
		if loadResult == OK:
			imageTexture = ImageTexture.create_from_image(image)

		var imageTextureRect = TextureRect.new()
		imageTextureRect.texture = imageTexture
		imageTextureRect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		imageTextureRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		imageTextureRect.size_flags_horizontal = SIZE_EXPAND_FILL
		imageTextureRect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		paginationContent.push_back(imageTextureRect)
