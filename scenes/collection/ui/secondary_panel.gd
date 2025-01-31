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


####################################################################################################
# Deregisters from signals.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.COLL_UPDATE_WIDGET_CONTENT, _update_widget_content)


####################################################################################################
# Move the cursor on input events.
####################################################################################################
func _input(event):
	if event is InputEventMouseMotion:
		# Move our cursor
		var mouse_motion : InputEventMouseMotion = event
		$Cursor.position = mouse_motion.position - Vector2(20, 20)
		

####################################################################################################
# Called every frame to render the panel.
####################################################################################################
func _process(_delta):
	if sceneLoaded:
		sceneLoaded = false
		$FallbackPanel.visible = false
		add_child(secondarySceneInstance)

		

func _update_widget_content(widgetSceneData: WidgetSceneData) -> void:
	if secondarySceneInstance:
		remove_child(secondarySceneInstance)
		secondarySceneInstance.queue_free()

	sceneLoaderThread = Thread.new()
	sceneLoaderThread.start(_load_widget_scene.bind(widgetSceneData), Thread.PRIORITY_LOW)


func _load_widget_scene(widgetSceneData: WidgetSceneData) -> void:
	var secondaryScene: Resource = load(widgetSceneData.secondaryPanelScene)
	secondarySceneInstance = secondaryScene.instantiate()
	secondarySceneInstance.initialize(widgetSceneData.widget)
	sceneLoaded = true
