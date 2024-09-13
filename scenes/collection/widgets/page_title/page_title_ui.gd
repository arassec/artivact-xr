extends Node



func initialize(widget: PageTitleWidget):
	if widget == null:
		return
		
	var titleLabel = find_child("TitleLabel")
	if titleLabel != null:
		titleLabel.text = widget.title.translate()

	var coverPictureTextureRect = find_child("CoverPictureTextureRect")
	if coverPictureTextureRect != null && widget.backgroundImage != null:
		coverPictureTextureRect.texture = _create_title_image(widget)
			
			

func _create_title_image(widget: PageTitleWidget) -> ImageTexture:
	var result = null
	
	if widget == null || widget.backgroundImage == null:
		return result
	
	var imageFile = widget.backgroundImage
	var img = CollectionStore.get_collection_zip_reader().read_file(str(widget.id, "/", imageFile))
	
	var image = Image.new()
	var loadResult = ERR_UNAVAILABLE
	if imageFile.ends_with("jpg") || imageFile.ends_with("JPG") || imageFile.ends_with("jpeg") || imageFile.ends_with("JPEG"):
		loadResult = image.load_jpg_from_buffer(img)
	elif imageFile.ends_with("png") || imageFile.ends_with("PNG"):
		loadResult = image.load_png_from_buffer(img)

	if loadResult == OK:
		result = ImageTexture.create_from_image(image)

	return result
