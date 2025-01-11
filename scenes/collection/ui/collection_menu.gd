extends Control


var pages: Array[ArtivactMenuJson] = []
var pageIndex = 0

var widgets: Array[Widget] = []
var widgetIndex = 0

var items: Array[String] = []
var itemIndex = 0

var infoDataVisible = true
var itemDataVisible = false


####################################################################################################
# Registers for signals.
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.COLL_UPDATE_PAGE_NAV, _update_page_nav)
	SignalBus.register(SignalBus.SignalType.COLL_UPDATE_WIDGET_NAV, _update_widget_nav)
	SignalBus.register(SignalBus.SignalType.COLL_ITEM_UPDATE_PAGINATOR, _update_item_nav)


####################################################################################################
# Deregisters from signals.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.COLL_UPDATE_PAGE_NAV, _update_page_nav)
	SignalBus.deregister(SignalBus.SignalType.COLL_UPDATE_WIDGET_NAV, _update_widget_nav)
	SignalBus.deregister(SignalBus.SignalType.COLL_ITEM_UPDATE_PAGINATOR, _update_item_nav)


####################################################################################################
# Move the cursor on input events.
####################################################################################################
func _input(event):
	if event is InputEventMouseMotion:
		# Move our cursor
		var mouse_motion : InputEventMouseMotion = event
		$Cursor.position = mouse_motion.position - Vector2(20, 5)


func _update_page_nav(pagesInput: Array[ArtivactMenuJson]):
	_hide_item_navigation()
	pages = pagesInput
	pageIndex = 0
	widgetIndex = 0
	if pages.size() > 1:
		$CollectionMenuPanel/MarginContainer/VBoxContainer/PageNavVBoxContainer.visible = true
		_update_page_nav_labels()
	else:
		$CollectionMenuPanel/MarginContainer/VBoxContainer/PageNavVBoxContainer.visible = false


func _update_widget_nav(widgetsInput: Array[Widget]):
	_hide_item_navigation()
	widgets = widgetsInput
	widgetIndex = 0
	if widgets.size() > 0:
		infoDataVisible = true
		$CollectionMenuPanel/MarginContainer/VBoxContainer/WidgetNavVBoxContainer.visible = true
		_update_widget_nav_labels()
	else:
		infoDataVisible = false
		$CollectionMenuPanel/MarginContainer/VBoxContainer/WidgetNavVBoxContainer.visible = false


func _update_item_nav(itemsInput: Array[String]):
	items = itemsInput
	itemIndex = 0
	if items.size() > 0:
		SignalBus.trigger(SignalBus.SignalType.COLL_ITEM_SHOW_DATA)
		$CollectionMenuPanel/MarginContainer/VBoxContainer/ItemNavVBoxContainer.visible = true
		_update_item_nav_labels()
		if items.size() == 1:
			$CollectionMenuPanel/MarginContainer/VBoxContainer/ItemNavVBoxContainer/ItemNavHBoxContainer.visible = false
		else:
			$CollectionMenuPanel/MarginContainer/VBoxContainer/ItemNavVBoxContainer/ItemNavHBoxContainer.visible = true
	else:
		$CollectionMenuPanel/MarginContainer/VBoxContainer/ItemNavVBoxContainer.visible = false


func _update_page_nav_labels():
	if pages.size() > 0:
		$CollectionMenuPanel/MarginContainer/VBoxContainer/PageNavVBoxContainer/PageLabel.text = pages[pageIndex].translate()
		$CollectionMenuPanel/MarginContainer/VBoxContainer/PageNavVBoxContainer/PageNavHBoxContainer/PagePaginatorLabel.text = str(pageIndex + 1, " / ", pages.size())
	
	
func _update_widget_nav_labels():
	if widgets.size() > 0:
		$CollectionMenuPanel/MarginContainer/VBoxContainer/WidgetNavVBoxContainer/WidgetLabel.text = widgets[widgetIndex].label();
		$CollectionMenuPanel/MarginContainer/VBoxContainer/WidgetNavVBoxContainer/WidgetNavHBoxContainer/WidgetPaginatorLabel.text = str(widgetIndex + 1, " / ", widgets.size())
	

func _update_item_nav_labels():
	if items.size() > 0:
		itemDataVisible = true
		SignalBus.trigger(SignalBus.SignalType.COLL_ITEM_SHOW_DATA)
		$CollectionMenuPanel/MarginContainer/VBoxContainer/ItemNavVBoxContainer/ItemLabel.text = items[itemIndex];
		$CollectionMenuPanel/MarginContainer/VBoxContainer/ItemNavVBoxContainer/ItemNavHBoxContainer/ItemPaginatorLabel.text = str(itemIndex + 1, " / ", items.size())
	

func _on_quit_button_pressed():
	SignalBus.trigger(SignalBus.SignalType.COLL_QUIT_COLLECTION)


func _on_previous_page_button_pressed() -> void:
	if pageIndex == 0:
		return
	pageIndex = pageIndex - 1
	_hide_item_navigation()
	_update_page_nav_labels()
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_PAGE, pages[pageIndex].id)


func _on_next_page_button_pressed() -> void:
	if pageIndex == pages.size() -1:
		return
	pageIndex = pageIndex + 1
	_hide_item_navigation()
	_update_page_nav_labels()
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_PAGE, pages[pageIndex].id)


func _on_previous_widget_button_pressed() -> void:
	if widgetIndex == 0:
		return
	widgetIndex = widgetIndex - 1
	_hide_item_navigation()
	_update_widget_nav_labels()
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_WIDGET, widgets[widgetIndex].id)


func _on_next_widget_button_pressed() -> void:
	if widgetIndex == widgets.size() - 1:
		return
	widgetIndex = widgetIndex + 1
	_hide_item_navigation()
	_update_widget_nav_labels()
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_WIDGET, widgets[widgetIndex].id)


func _on_previous_item_button_pressed() -> void:
	if itemIndex == 0:
		return
	itemIndex = itemIndex - 1
	_update_item_nav_labels()
	SignalBus.trigger(SignalBus.SignalType.COLL_ITEM_PREVIOUS)


func _on_next_item_button_pressed() -> void:
	if itemIndex == items.size() - 1:
		return
	itemIndex = itemIndex + 1
	_update_item_nav_labels()
	SignalBus.trigger(SignalBus.SignalType.COLL_ITEM_NEXT)


func _hide_item_navigation():
	itemDataVisible = false
	$CollectionMenuPanel/MarginContainer/VBoxContainer/ItemNavVBoxContainer.visible = false
	SignalBus.trigger(SignalBus.SignalType.COLL_ITEM_HIDE_DATA)


func _on_info_button_pressed() -> void:
	if infoDataVisible:
		SignalBus.trigger(SignalBus.SignalType.COLL_ITEM_HIDE_INFO)
		infoDataVisible = false
	else:
		SignalBus.trigger(SignalBus.SignalType.COLL_ITEM_SHOW_INFO)
		infoDataVisible = true


func _on_data_button_pressed() -> void:
	if itemDataVisible:
		SignalBus.trigger(SignalBus.SignalType.COLL_ITEM_HIDE_DATA)
		itemDataVisible = false
	else:
		SignalBus.trigger(SignalBus.SignalType.COLL_ITEM_SHOW_DATA)
		itemDataVisible = true
