extends Node


var widget

func initialize(widgetInput: TextWidget):
	widget = widgetInput

	
func _ready():
	var pageTitleUiViewport = $TextUiViewport2Din3D
	var pageTitleUi = pageTitleUiViewport.get_scene_instance()
	if pageTitleUi != null:
		pageTitleUi.initialize(widget)
