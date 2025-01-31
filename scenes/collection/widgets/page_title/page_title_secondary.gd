extends Node


func initialize(widget: PageTitleWidget):
	if widget == null:
		return
		
	var titleLabel = find_child("TitleLabel")
	if titleLabel != null:
		titleLabel.text = widget.title.translate()

	# Load cover picture if available:
	if widget.backgroundImage != null && widget.backgroundImage != "":
		var imageFile = widget.backgroundImage
		var img = CollectionStore.get_collection_zip_reader(CollectionStore.get_selected_collection()).read_file(str(widget.id, "/", imageFile))
	
		var image = Image.new()
		var loadResult = ERR_UNAVAILABLE
		if imageFile.ends_with("jpg") || imageFile.ends_with("JPG") || imageFile.ends_with("jpeg") || imageFile.ends_with("JPEG"):
			loadResult = image.load_jpg_from_buffer(img)
		elif imageFile.ends_with("png") || imageFile.ends_with("PNG"):
			loadResult = image.load_png_from_buffer(img)

		var coverPicture: ImageTexture = null
		if loadResult == OK:
			coverPicture = ImageTexture.create_from_image(image)

		var coverPictureTextureRect = find_child("CoverPictureTextureRect")
		
		if coverPictureTextureRect != null && coverPicture != null:
			coverPictureTextureRect.texture = coverPicture
