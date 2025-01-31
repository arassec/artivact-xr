extends Control

var widget: Widget


func initialize(widgetInput: Widget, fontSize: int) -> void:
	widget = widgetInput
	find_child("SectionButton").text = widget.label()
	find_child("SectionButton").set("theme_override_font_sizes/font_size", fontSize)


func _on_section_button_pressed() -> void:
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_WIDGET, widget.id)
