extends Control


var secondarySceneInstance
var sceneLoaded: bool = false
var sceneLoaderThread: Thread


####################################################################################################
# Registers for signals.
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.COLL_UPDATE_WIDGET_CONTENT, _update_widget_content)
	SignalBus.register(SignalBus.SignalType.COLL_CLOSE_WIDGET, _remove_widget_content)


####################################################################################################
# Deregisters from signals.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.COLL_UPDATE_WIDGET_CONTENT, _update_widget_content)
	SignalBus.deregister(SignalBus.SignalType.COLL_CLOSE_WIDGET, _remove_widget_content)


####################################################################################################
# Called every frame to render the panel.
####################################################################################################
func _process(_delta):
	if sceneLoaded:
		sceneLoaded = false
		add_child(secondarySceneInstance)
		sceneLoaderThread.wait_to_finish()
		sceneLoaderThread = null
		$FallbackPanel.visible = false


func _update_widget_content(widgetSceneData: WidgetSceneData) -> void:
	if sceneLoaderThread != null:
		sceneLoaderThread.wait_to_finish()

	$FallbackPanel.visible = true

	sceneLoaderThread = Thread.new()
	sceneLoaderThread.start(_load_widget_scene.bind(widgetSceneData), Thread.PRIORITY_LOW)


func _remove_widget_content() -> void:
	if secondarySceneInstance:
		remove_child(secondarySceneInstance)
		secondarySceneInstance.queue_free()
		secondarySceneInstance = null
	

func _load_widget_scene(widgetSceneData: WidgetSceneData) -> void:
	var secondaryScene: Resource = load(widgetSceneData.secondaryPanelScene)
	if secondaryScene:
		secondarySceneInstance = secondaryScene.instantiate()
		secondarySceneInstance.initialize(widgetSceneData.widget)
	sceneLoaded = true
