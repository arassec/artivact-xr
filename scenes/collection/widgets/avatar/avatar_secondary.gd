extends Control



func initialize(widget: AvatarWidget):
	if widget == null:
		return
		
	var avatarSubtextLabel = find_child("AvatarSubtextLabel")
	if avatarSubtextLabel != null:
		avatarSubtextLabel.text = widget.avatarSubtext.translate()

	SignalBus.debug({"Avatar": widget.avatarImage})

	# Load avatar image if available:
	if widget.avatarImage != null && widget.avatarImage != "":
		var imageFile = widget.avatarImage
		var img = CollectionStore.get_collection_zip_reader(CollectionStore.get_selected_collection()).read_file(str(widget.id, "/", imageFile))
	
		var image = Image.new()
		var loadResult = ERR_UNAVAILABLE
		if imageFile.ends_with("jpg") || imageFile.ends_with("JPG") || imageFile.ends_with("jpeg") || imageFile.ends_with("JPEG"):
			loadResult = image.load_jpg_from_buffer(img)
		elif imageFile.ends_with("png") || imageFile.ends_with("PNG"):
			loadResult = image.load_png_from_buffer(img)

		var avatarImage: ImageTexture = null
		if loadResult == OK:
			avatarImage = ImageTexture.create_from_image(image)

		var avatarImageTextureRect = find_child("AvatarImageTextureRect")
		
		if avatarImageTextureRect != null && avatarImage != null:
			avatarImageTextureRect.texture = avatarImage
