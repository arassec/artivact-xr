extends Control



func initialize(widget: ImageTextWidget):
	if widget == null:
		return
		
	var textLabel = find_child("TextLabel")
	if textLabel != null:
		textLabel.text = widget.text.translate()
