extends Control


var pages: Array[ArtivactMenuJson] = []
var pageIndex = 0

var widgets: Array[Widget] = []
var widgetIndex = 0


####################################################################################################
# Registers for signals.
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.COLL_UPDATE_PAGE_NAV, _update_page_nav)
	SignalBus.register(SignalBus.SignalType.COLL_UPDATE_WIDGET_NAV, _update_widget_nav)


####################################################################################################
# Deregisters from signals.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.COLL_UPDATE_PAGE_NAV, _update_page_nav)
	SignalBus.deregister(SignalBus.SignalType.COLL_UPDATE_WIDGET_NAV, _update_widget_nav)


####################################################################################################
# Move the cursor on input events.
####################################################################################################
func _input(event):
	if event is InputEventMouseMotion:
		# Move our cursor
		var mouse_motion : InputEventMouseMotion = event
		$Cursor.position = mouse_motion.position - Vector2(20, 20)


func _update_page_nav(pagesInput: Array[ArtivactMenuJson]):
	pages = pagesInput
	pageIndex = 0
	widgetIndex = 0
	if pages.size() > 1:
		$CollectionMenuPanel/MarginContainer/VBoxContainer/PageSeparator.visible = true
		$CollectionMenuPanel/MarginContainer/VBoxContainer/PageLabel.visible = true
		$CollectionMenuPanel/MarginContainer/VBoxContainer/PageNavHBoxContainer.visible = true
		_update_page_nav_labels()
	else:
		$CollectionMenuPanel/MarginContainer/VBoxContainer/PageSeparator.visible = false
		$CollectionMenuPanel/MarginContainer/VBoxContainer/PageLabel.visible = false
		$CollectionMenuPanel/MarginContainer/VBoxContainer/PageNavHBoxContainer.visible = false


func _update_widget_nav(widgetsInput: Array[Widget]):
	widgets = widgetsInput
	widgetIndex = 0
	if widgets.size() > 0:
		$CollectionMenuPanel/MarginContainer/VBoxContainer/WidgetSeparator.visible = true
		$CollectionMenuPanel/MarginContainer/VBoxContainer/WidgetLabel.visible = true;
		$CollectionMenuPanel/MarginContainer/VBoxContainer/WidgetNavHBoxContainer.visible = true;
		_update_widget_nav_labels()
	else:
		$CollectionMenuPanel/MarginContainer/VBoxContainer/WidgetSeparator.visible = false
		$CollectionMenuPanel/MarginContainer/VBoxContainer/WidgetLabel.visible = false;
		$CollectionMenuPanel/MarginContainer/VBoxContainer/WidgetNavHBoxContainer.visible = false;


func _update_page_nav_labels():
	if pages.size() > 0:
		$CollectionMenuPanel/MarginContainer/VBoxContainer/PageLabel.text = pages[pageIndex].translate()
		$CollectionMenuPanel/MarginContainer/VBoxContainer/PageNavHBoxContainer/PagePaginatorLabel.text = str(pageIndex + 1, " / ", pages.size())
	
	
func _update_widget_nav_labels():
	if widgets.size() > 0:
		$CollectionMenuPanel/MarginContainer/VBoxContainer/WidgetLabel.text = widgets[widgetIndex].label();
		$CollectionMenuPanel/MarginContainer/VBoxContainer/WidgetNavHBoxContainer/WidgetPaginatorLabel.text = str(widgetIndex + 1, " / ", widgets.size())
	

func _on_quit_button_pressed():
	SignalBus.trigger(SignalBus.SignalType.COLL_QUIT_COLLECTION)


func _on_previous_page_button_pressed() -> void:
	if pageIndex == 0:
		return
	pageIndex = pageIndex - 1
	_update_page_nav_labels()
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_PAGE, pages[pageIndex].id)


func _on_next_page_button_pressed() -> void:
	if pageIndex == pages.size() -1:
		return
	pageIndex = pageIndex + 1
	_update_page_nav_labels()
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_PAGE, pages[pageIndex].id)


func _on_previous_widget_button_pressed() -> void:
	if widgetIndex == 0:
		return
	widgetIndex = widgetIndex - 1
	_update_widget_nav_labels()
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_WIDGET, widgets[widgetIndex].id)


func _on_next_widget_button_pressed() -> void:
	if widgetIndex == widgets.size() - 1:
		return
	widgetIndex = widgetIndex + 1
	_update_widget_nav_labels()
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_WIDGET, widgets[widgetIndex].id)
