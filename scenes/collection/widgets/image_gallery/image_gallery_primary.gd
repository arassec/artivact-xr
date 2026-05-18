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
	

func _load_images():
	
	# Load images if available:
	for imageFile in widget.images:
		var imgFilePath = PathUtil.get_file_path(ComponentType.WIDGET, widget.id, imageFile)
		var img = CollectionStore.get_collection_zip_reader(CollectionStore.get_selected_collection()).read_file(imgFilePath)
	
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
		imageTextureRect.stretch_mode = TextureRect.STRETCH_SCALE
		imageTextureRect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		imageTextureRect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		paginationContent.push_back(imageTextureRect)
