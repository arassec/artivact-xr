extends Control

var chapterCardScene: Resource = load("res://scenes/collection/ui/chapter_card.tscn")
var sectionCardScene: Resource = load("res://scenes/collection/ui/section_card.tscn")


var pages: Array[ArtivactMenuJson] = []
var selectedPage: String

var widgets: Array[Widget] = []
var selectedWidget: String

var pageBreadcrumb: String = ''
var widgetBreadcrumb: String = ''

var widgetContentSceneInstance


####################################################################################################
# Registers for signals.
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.COLL_UPDATE_PAGE_NAV, _update_page_nav)
	SignalBus.register(SignalBus.SignalType.COLL_UPDATE_WIDGET_NAV, _update_widget_nav)
	SignalBus.register(SignalBus.SignalType.COLL_OPEN_PAGE, _page_selected)
	SignalBus.register(SignalBus.SignalType.COLL_OPEN_WIDGET, _widget_selected)
	SignalBus.register(SignalBus.SignalType.COLL_UPDATE_WIDGET_CONTENT, _update_widget_content)


####################################################################################################
# Deregisters from signals.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.COLL_UPDATE_PAGE_NAV, _update_page_nav)
	SignalBus.deregister(SignalBus.SignalType.COLL_UPDATE_WIDGET_NAV, _update_widget_nav)
	SignalBus.deregister(SignalBus.SignalType.COLL_OPEN_PAGE, _page_selected)
	SignalBus.deregister(SignalBus.SignalType.COLL_OPEN_WIDGET, _widget_selected)
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
# Creates the page navigation buttons.
####################################################################################################
func _update_page_nav(pagesInput: Array[ArtivactMenuJson]):
	pages = pagesInput
	
	var fontSize = _compute_font_size(pages)
	var content: Array[Object] = []

	for page in pages:
		var cardSceneInstance = chapterCardScene.instantiate()
		cardSceneInstance.initialize(page, fontSize)
		content.push_back(cardSceneInstance)

	find_child("PaginationContainer").set_content(content)
	
	find_child("QuitButton").visible = true
	find_child("WidgetBackButton").visible = false
	find_child("WidgetContentBackButton").visible = false
	find_child("BreadcrumbLabel").visible = false

	find_child("PaginationContainer").visible = true
	find_child("WidgetContentAnchor").visible = false
		
	if pages.size() == 1:
		SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_PAGE, pages[0].id)


####################################################################################################
# Creates the widget navigation buttons.
####################################################################################################
func _update_widget_nav(widgetsInput: Array[Widget]):
	widgets = widgetsInput

	var fontSize = _compute_font_size(widgets)
	var content: Array[Object] = []

	for widget in widgets:
		var cardSceneInstance = sectionCardScene.instantiate()
		cardSceneInstance.initialize(widget, fontSize)
		content.push_back(cardSceneInstance)

	find_child("PaginationContainer").set_content(content)
	
	if pages.size() > 1:
		find_child("QuitButton").visible = false
		find_child("WidgetBackButton").visible = true
	else:
		find_child("QuitButton").visible = true
		find_child("WidgetBackButton").visible = false

	find_child("WidgetContentBackButton").visible = false

	find_child("PaginationContainer").visible = true
	find_child("WidgetContentAnchor").visible = false
	
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_WIDGET, widgets[0].id)


func _page_selected(menuId: String) -> void:
	if pages.size() == 1:
		return
	for page in pages:
		if page.id == menuId:
			pageBreadcrumb = page.translate()
			_update_breadcrumb()


func _widget_selected(widgetId: String) -> void:
	for widget in widgets:
		if widget.id == widgetId:
			widgetBreadcrumb = widget.label()
			_update_breadcrumb()


func _update_widget_content(widgetSceneData: WidgetSceneData) -> void:
	if widgetSceneData.primaryPanelScene:
		var widgetScene: Resource = load(widgetSceneData.primaryPanelScene)
		widgetContentSceneInstance = widgetScene.instantiate()
		widgetContentSceneInstance.initialize(widgetSceneData.widget)
		
		find_child("QuitButton").visible = false
		find_child("WidgetBackButton").visible = false
		find_child("WidgetContentBackButton").visible = true
		find_child("PaginationContainer").visible = false
		
		var widgetContentAnchor = find_child("WidgetContentAnchor")
		widgetContentAnchor.visible = true
		widgetContentAnchor.add_child(widgetContentSceneInstance)


func _update_breadcrumb() -> void:
	var breadcrumbLabel = find_child("BreadcrumbLabel")
	if pageBreadcrumb == '' && widgetBreadcrumb == '':
		breadcrumbLabel.visible = false
	else:
		breadcrumbLabel.visible = true
		if pageBreadcrumb != '' && widgetBreadcrumb != '':
			breadcrumbLabel.text = str(pageBreadcrumb, " / ", widgetBreadcrumb)
		elif pageBreadcrumb != '':
			breadcrumbLabel.text = pageBreadcrumb
		elif widgetBreadcrumb != '':
			breadcrumbLabel.text = widgetBreadcrumb
			

func _on_widget_back_button_pressed() -> void:
	pageBreadcrumb = ''
	widgetBreadcrumb = ''
	_update_breadcrumb()
	_update_page_nav(pages)


func _on_widget_content_back_button_pressed() -> void:
	find_child("WidgetContentAnchor").remove_child(widgetContentSceneInstance)
	widgetContentSceneInstance.queue_free()
	_update_widget_nav(widgets)


func _on_quit_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.COLL_QUIT_COLLECTION)


func _compute_font_size(content) -> int:
	var fontSize = 64
	if content.size() >= 6:
		fontSize = 48
	elif content.size() >= 9:
		fontSize = 24
	return fontSize
