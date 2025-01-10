extends Control


var sceneLoaderThread: Thread

var contentNode: Node = null
var contentLoaded = false


func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.WIDGET_CONTENT_LOAD, _load_widget_content)
	SignalBus.register(SignalBus.SignalType.WIDGET_CONTENT_CLEAR, _clear_widget_content)


func _exit_tree():
	# Deregister signals:
	SignalBus.deregister(SignalBus.SignalType.WIDGET_CONTENT_LOAD, _load_widget_content)
	SignalBus.deregister(SignalBus.SignalType.WIDGET_CONTENT_CLEAR, _clear_widget_content)


func _input(event):
	if event is InputEventMouseMotion:
		var mouse_motion : InputEventMouseMotion = event
		$Cursor.position = mouse_motion.position - Vector2(20, 20)


func _process(delta):
	if contentLoaded:
		contentLoaded = false
		$MenuContainer/WidgetContent.add_child(contentNode)


func _clear_widget_content():
	if contentNode != null:
		var widgetContentAnchor = find_child("WidgetContent")
		if widgetContentAnchor != null:
			widgetContentAnchor.remove_child(contentNode)
			contentNode.queue_free()
			contentNode = null


func _load_widget_content(sceneData: Dictionary):
	_clear_widget_content()

	if sceneData.has("scene") and sceneData.has("widget"):
		sceneLoaderThread = Thread.new()
		sceneLoaderThread.start(_load_scene.bind(sceneData), Thread.PRIORITY_LOW)


func _load_scene(sceneData: Dictionary):
	var contentScene: Resource = load(sceneData.scene)
	contentNode = contentScene.instantiate()
	contentNode.initialize(sceneData.widget)
	contentLoaded = true
