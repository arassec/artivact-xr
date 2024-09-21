extends Node


var coverPicture: ImageTexture

var coverPictureLoaderThread: Thread
var coverPictureLoaded = false


func initialize(widget: PageTitleWidget):
	if widget == null:
		return
		
	var titleLabel = find_child("TitleLabel")
	if titleLabel != null:
		titleLabel.text = widget.title.translate()

	if widget.backgroundImage != null && widget.backgroundImage != "":
		coverPictureLoaderThread = Thread.new()
		coverPictureLoaderThread.start(_load_cover_picture.bind(widget), Thread.PRIORITY_LOW)


func _process(delta):
	if coverPictureLoaded:
		coverPictureLoaded = false
		coverPictureLoaderThread.wait_to_finish()
		_create_title_image()


func _load_cover_picture(widget: PageTitleWidget):
	if widget == null || widget.backgroundImage == null:
		return
	
	var imageFile = widget.backgroundImage
	var img = CollectionStore.get_collection_zip_reader().read_file(str(widget.id, "/", imageFile))
	
	var image = Image.new()
	var loadResult = ERR_UNAVAILABLE
	if imageFile.ends_with("jpg") || imageFile.ends_with("JPG") || imageFile.ends_with("jpeg") || imageFile.ends_with("JPEG"):
		loadResult = image.load_jpg_from_buffer(img)
	elif imageFile.ends_with("png") || imageFile.ends_with("PNG"):
		loadResult = image.load_png_from_buffer(img)

	if loadResult == OK:
		coverPicture = ImageTexture.create_from_image(image)
		
	coverPictureLoaded = true



func _create_title_image():
	var coverPictureTextureRect = find_child("CoverPictureTextureRect")
	if coverPictureTextureRect != null && coverPicture != null:
		coverPictureTextureRect.texture = coverPicture
		
