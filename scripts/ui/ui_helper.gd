class_name UiHelper

extends Object


static func create_menu_button(label: String, callback: Callable) -> Button:
	var button = Button.new()
	button.theme = load("res://themes/default_ui.tres")
	button.text = label
	button.set("theme_override_font_sizes/font_size", 32)
	button.pressed.connect(callback)
	return button
