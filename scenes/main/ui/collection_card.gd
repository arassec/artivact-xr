extends Control


var handleHovering: bool = true
var hovered: bool = false

var collectionInfo: CollectionInfo


func initialize(collectionInfoInput: CollectionInfo, fontSize: int) -> void:
	collectionInfo = collectionInfoInput
	
	find_child("ContentCoverColorRect").visible = false
	
	var fontSizeTitle = fontSize
	var fontSizeDescription = fontSize * 0.7
	var fontSizeSmall = fontSize / 2
	
	find_child("TitleLabel").text = collectionInfo.title
	find_child("TitleLabel").set("theme_override_font_sizes/font_size", fontSize)

	if collectionInfo.coverPicture == null:
		find_child("FallbackTitleLabel").text = collectionInfo.title
		find_child("FallbackTitleLabel").visible = true
		find_child("FallbackTitleLabel").set("theme_override_font_sizes/font_size", fontSize)
	
	find_child("DescriptionLabel").text = collectionInfo.description
	find_child("DescriptionLabel").set("theme_override_font_sizes/font_size", fontSizeDescription)
	
	find_child("DetailsLabel").text = collectionInfo.get_formatted_filesize()
	find_child("DetailsLabel").set("theme_override_font_sizes/font_size", fontSizeSmall)
	
	find_child("DeleteButton").set("theme_override_font_sizes/font_size", 32)
	
	var coverPictureTextureRect = find_child("CoverPictureTextureRect")
	if coverPictureTextureRect != null && collectionInfo.coverPicture != null:
		coverPictureTextureRect.texture = collectionInfo.coverPicture
	elif coverPictureTextureRect != null:
		coverPictureTextureRect.texture = null

	if collectionInfo.fileSize > 0:
		find_child("DeleteButton").visible = true
		find_child("DownloadTextureRect").visible = false
	else:
		find_child("DeleteButton").visible = false
		find_child("DownloadTextureRect").visible = true


func _input(event):
	if event is InputEventMouseButton:
		if hovered && event.pressed:
			if (collectionInfo.fileSize == 0 && collectionInfo.fileSizeRemote > 0) || collectionInfo.update_available():
				SignalBus.trigger_with_payload(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION, collectionInfo.id)
			elif collectionInfo.fileSize > 0:
				SignalBus.trigger_with_payload(SignalBus.SignalType.MAIN_OPEN_COLLECTION, collectionInfo.id)


func _on_mouse_entered() -> void:
	if handleHovering:
		find_child("ContentCoverColorRect").visible = true
		hovered = true


func _on_mouse_exited() -> void:
	if handleHovering:
		find_child("ContentCoverColorRect").visible = false
		hovered = false


func _on_mouse_entered_ignore() -> void:
	find_child("ContentCoverColorRect").visible = true
	handleHovering = false


func _on_mouse_exited_ignore() -> void:
	find_child("ContentCoverColorRect").visible = true
	handleHovering = true


func _on_delete_button_pressed() -> void:
	SignalBus.trigger_with_payload(SignalBus.SignalType.MAIN_DELETE_COLLECTION, collectionInfo.id)
