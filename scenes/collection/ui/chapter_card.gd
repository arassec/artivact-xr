extends Control

var menu: ArtivactMenuJson
var handleHovering: bool = true


func initialize(menuInput: ArtivactMenuJson, fontSize: int) -> void:
	menu = menuInput
	
	find_child("ChapterButton").text = menu.translate()
	find_child("ChapterButton").set("theme_override_font_sizes/font_size", fontSize)


func _on_chapter_button_pressed() -> void:
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_PAGE, menu.id)
