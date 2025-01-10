extends Node


var selectedWidgetId: String

# Contains buttons indexed by the widget ID:
#   widgetId -> button instance
var buttons: Dictionary = {}


func _init():
	SignalBus.register(SignalBus.SignalType.UPDATE_WIDGET_NAVIGATION, _update_widget_navigation)
	

func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.UPDATE_WIDGET_NAVIGATION, _update_widget_navigation)


####################################################################################################
# Configures fallback keyboard shortcuts to test the application without XR device.
####################################################################################################
func _input(event):
	if event is InputEventKey && !event.pressed && event.keycode == Key.KEY_0:
		if buttons.size() > 0:
			SignalBus.trigger_with_payload(SignalBus.SignalType.OPEN_WIDGET, buttons.keys()[0])
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_9:
		if buttons.size() > 1:
			SignalBus.trigger_with_payload(SignalBus.SignalType.OPEN_WIDGET, buttons.keys()[1])
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_8:
		if buttons.size() > 2:
			SignalBus.trigger_with_payload(SignalBus.SignalType.OPEN_WIDGET, buttons.keys()[2])
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_7:
		if buttons.size() > 3:
			SignalBus.trigger_with_payload(SignalBus.SignalType.OPEN_WIDGET, buttons.keys()[3])


func _update_widget_navigation(widgetsInput: Array[Widget]):
	
	buttons.clear()

	var buttonContainer = find_child("ButtonContainer")
	for button in buttonContainer.get_children():
		buttonContainer.remove_child(button)
		button.queue_free()
	
	if widgetsInput != null && widgetsInput.size() > 0:
		var firstButton = true
		for widget in widgetsInput:
			if widget.type == Widget.WidgetType.SPACE:
				continue
			_create_button(buttonContainer, widget)
			if firstButton:
				selectedWidgetId = widget.id
				firstButton = false
	

func _create_button(buttonContainer: VBoxContainer, widget: Widget):
	var button = UiHelper.create_menu_button(widget.label(), _open_widget.bind(widget.id))
	buttonContainer.add_child(button)
	buttons[widget.id] = button


func _open_widget(widgetId: String):
	if widgetId != selectedWidgetId:
		selectedWidgetId = widgetId
		SignalBus.trigger_with_payload(SignalBus.SignalType.OPEN_WIDGET, widgetId)
