class_name UiHelper

extends Object


static func create_menu_button(label: String, callback: Callable) -> Button:
	var button = Button.new()
	button.theme = load("res://themes/default_ui.tres")
	button.text = label
	button.set("theme_override_font_sizes/font_size", 120)
	button.pressed.connect(callback)
	return button
	

static func create_menu_button_container(button: Button) -> MarginContainer:
	var marginContainer = MarginContainer.new()
	marginContainer.add_theme_constant_override("margin_left", 10)
	marginContainer.add_theme_constant_override("margin_right", 10)
	marginContainer.add_theme_constant_override("margin_top", 50)
	marginContainer.add_child(button)
	return marginContainer
	
	
