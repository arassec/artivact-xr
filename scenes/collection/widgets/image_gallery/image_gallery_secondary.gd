extends Control


func initialize(widget: ImageGalleryWidget):
	if widget == null:
		return
		
	var headingLabel = find_child("HeadingLabel")
	if headingLabel != null:
		headingLabel.text = widget.heading.translate()
		
	var contentLabel = find_child("ContentLabel")
	if contentLabel != null:
		contentLabel.text = widget.content.translate()
