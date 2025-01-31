extends Node



func initialize(widget: InfoBoxWidget):
	if widget == null:
		return

	var headingLabel = find_child("HeadingLabel")
	if headingLabel != null:
		headingLabel.text = widget.heading.translate()
		
	var contentLabel = find_child("ContentLabel")
	if contentLabel != null:
		contentLabel.text = widget.content.translate()

	var boxTypeColorRect = find_child("BoxTypeColorRect")
	if boxTypeColorRect != null:
		if InfoBoxWidget.BoxType.INFO == widget.boxType:
			boxTypeColorRect.color = Color("#87a3305e")
		elif InfoBoxWidget.BoxType.WARN == widget.boxType:
			boxTypeColorRect.color = Color("#e6c2295e")
		elif InfoBoxWidget.BoxType.ALERT == widget.boxType:
			boxTypeColorRect.color = Color("#a4031f5e")
