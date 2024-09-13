extends Node

var widget

func initialize(widgetInput: PageTitleWidget):
	widget = widgetInput

	
func _ready():
	var pageTitleUiViewport = $PageTitleUiViewport2Din3D
	var pageTitleUi = pageTitleUiViewport.get_scene_instance()
	if pageTitleUi != null:
		pageTitleUi.initialize(widget)
