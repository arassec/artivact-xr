extends Node


var selectedPageId: String

# Contains buttons indexed by the page ID:
#   pageId -> button instance
var buttons: Dictionary = {}


func _init():
	SignalBus.register(SignalBus.SignalType.UPDATE_PAGE_NAVIGATION, _update_page_navigation)
	

func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.UPDATE_PAGE_NAVIGATION, _update_page_navigation)


####################################################################################################
# Configures fallback keyboard shortcuts to test the application without XR device.
####################################################################################################
func _input(event):
	if event is InputEventKey && !event.pressed && event.keycode == Key.KEY_1:
		if buttons.size() > 0:
			SignalBus.trigger_with_payload(SignalBus.SignalType.OPEN_PAGE, buttons.keys()[0])
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_2:
		if buttons.size() > 1:
			SignalBus.trigger_with_payload(SignalBus.SignalType.OPEN_PAGE, buttons.keys()[1])
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_3:
		if buttons.size() > 2:
			SignalBus.trigger_with_payload(SignalBus.SignalType.OPEN_PAGE, buttons.keys()[2])


func _update_page_navigation(menusInput: Array[ArtivactMenuJson]):
	if menusInput != null && menusInput.size() > 0:
		selectedPageId = menusInput[0].targetPageId
		for menu in menusInput:
			_create_button(menu)
		_highlight_button(selectedPageId)
	

func _open_page(pageId: String):
	_highlight_button(pageId)
	selectedPageId = pageId
	SignalBus.trigger_with_payload(SignalBus.SignalType.OPEN_PAGE, pageId)


func _create_button(menu: ArtivactMenuJson):
	var button = UiHelper.create_menu_button(menu.translate(), _open_page.bind(menu.targetPageId))
	find_child("ButtonContainer").add_child(UiHelper.create_menu_button_container(button))
	buttons[menu.targetPageId] = button


func _highlight_button(pageId: String):
	buttons[selectedPageId].toggle_mode = true
	buttons[selectedPageId].set_pressed_no_signal(false)
	buttons[selectedPageId].toggle_mode = false
	buttons[pageId].toggle_mode = true
	buttons[pageId].set_pressed_no_signal(true)
	buttons[pageId].toggle_mode = false
