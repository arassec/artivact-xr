extends Control


func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.WIDGET_NAVIGATION_MENU_SHOW, _show_widget_navigation_menu)
	SignalBus.register(SignalBus.SignalType.WIDGET_NAVIGATION_MENU_HIDE, _hide_widget_navigation_menu)
	SignalBus.register(SignalBus.SignalType.WIDGET_NAVIGATION_MENU_UPDATE_PAGINATOR, _update_paginator_label)
	
	visible = false


func _exit_tree():
	# Deregister signals:
	SignalBus.deregister(SignalBus.SignalType.WIDGET_NAVIGATION_MENU_SHOW, _show_widget_navigation_menu)
	SignalBus.deregister(SignalBus.SignalType.WIDGET_NAVIGATION_MENU_HIDE, _hide_widget_navigation_menu)
	SignalBus.deregister(SignalBus.SignalType.WIDGET_NAVIGATION_MENU_UPDATE_PAGINATOR, _update_paginator_label)


func _show_widget_navigation_menu():
	visible = true

	
func _hide_widget_navigation_menu():
	visible = false
	

func _update_paginator_label(currentItemIndex: int, totalItems: int):
	var paginatorLabel = find_child("PaginatorLabel")
	paginatorLabel.text = str(currentItemIndex + 1, " / ", totalItems)


func _on_previous_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.WIDGET_NAVIGATION_MENU_PREVIOUS)


func _on_next_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.WIDGET_NAVIGATION_MENU_NEXT)


func _on_info_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.WIDGET_NAVIGATION_MENU_INFO)


func _on_data_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.WIDGET_NAVIGATION_MENU_DATA)
