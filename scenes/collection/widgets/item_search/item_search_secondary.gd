extends Control



var widget: ItemSearchWidget


func initialize(widgetInput: ItemSearchWidget):

	if widgetInput == null:
		return
				
	widget = widgetInput
			
	var headingLabel = find_child("HeadingLabel")
	if headingLabel != null:
		headingLabel.text = widget.heading.translate()
		
	var contentLabel = find_child("ContentLabel")
	if contentLabel != null:
		contentLabel.text = widget.content.translate()
