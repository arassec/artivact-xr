extends Node


var selectedWidgetId: String

# Contains buttons indexed by the widget ID:
#   pageId -> button instance
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


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _update_widget_navigation(widgetsInput: Array[Widget]):
	var buttonContainer = find_child("ButtonContainer")
	if buttonContainer != null:
		find_child("MarginContainer").remove_child(buttonContainer)
		buttonContainer.queue_free()
	buttons.clear()

	buttonContainer = VBoxContainer.new()
	buttonContainer.name = "ButtonContainer"
	
	if widgetsInput != null && widgetsInput.size() > 0:
		var firstButton = true
		for widget in widgetsInput:
			if widget.type == Widget.WidgetType.SPACE:
				continue
			_create_button(buttonContainer, widget)
			if firstButton:
				selectedWidgetId = widget.id
				firstButton = false
			
	find_child("MarginContainer").add_child(buttonContainer)


func _create_button(buttonContainer: VBoxContainer, widget: Widget):
	var button = UiHelper.create_menu_button(widget.label(), _open_widget.bind(widget.id))
	buttonContainer.add_child(UiHelper.create_menu_button_container(button))
	buttons[widget.id] = button


func _open_widget(widgetId: String):
	selectedWidgetId = widgetId
	SignalBus.trigger_with_payload(SignalBus.SignalType.OPEN_WIDGET, widgetId)
