extends Control

var chapterCardScene: Resource = load("res://scenes/collection/ui/chapter_card.tscn")
var sectionCardScene: Resource = load("res://scenes/collection/ui/section_card.tscn")


var pages: Array[ArtivactMenuJson] = []
var selectedPage: String

var widgets: Array[Widget] = []
var selectedWidget: String

var widgetContentSceneInstance

@onready var pause_voice_button: Button = $Panel/MarginContainer/VBoxContainer/NavigationMenu/PauseVoiceButton
@onready var resume_voice_button: Button = $Panel/MarginContainer/VBoxContainer/NavigationMenu/ResumeVoiceButton


####################################################################################################
# Registers for signals.
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.COLL_UPDATE_PAGE_NAV, _update_page_nav)
	SignalBus.register(SignalBus.SignalType.COLL_UPDATE_WIDGET_NAV, _update_widget_nav)
	SignalBus.register(SignalBus.SignalType.COLL_UPDATE_WIDGET_CONTENT, _update_widget_content)


####################################################################################################
# Deregisters from signals.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.COLL_UPDATE_PAGE_NAV, _update_page_nav)
	SignalBus.deregister(SignalBus.SignalType.COLL_UPDATE_WIDGET_NAV, _update_widget_nav)
	SignalBus.deregister(SignalBus.SignalType.COLL_UPDATE_WIDGET_CONTENT, _update_widget_content)


func _ready():
	var arMode = SettingsStore.get_value(SettingsStore.SettingType.AR_MODE)
	if arMode:
		var passthrough_button = find_child("PassthroughModeButton")
		if passthrough_button:
			passthrough_button.visible = false
		var immersive_button = find_child("ImmersiveModeButton")
		if immersive_button:
			immersive_button.visible = true
	else:
		var passthrough_button = find_child("PassthroughModeButton")
		if passthrough_button:
			passthrough_button.visible = true
		var immersive_button = find_child("ImmersiveModeButton")
		if immersive_button:
			immersive_button.visible = false

	var voiceEnabled = SettingsStore.get_value(SettingsStore.SettingType.VOICE_ENABLED)
	if voiceEnabled:
		pause_voice_button.visible = true
		resume_voice_button.visible = false
	else:
		pause_voice_button.visible = false
		resume_voice_button.visible = false


####################################################################################################
# Creates the page navigation buttons.
####################################################################################################
func _update_page_nav(pagesInput: Array[ArtivactMenuJson]):
	pages = pagesInput
	
	var fontSize = _compute_font_size(pages)
	var content: Array[Object] = []

	for page in pages:
		var cardSceneInstance = chapterCardScene.instantiate()
		cardSceneInstance.initialize(page, fontSize)
		content.push_back(cardSceneInstance)
		pass

	find_child("PaginationContainer").set_content(content)
	
	find_child("QuitButton").visible = true
	find_child("WidgetBackButton").visible = false
	find_child("WidgetContentBackButton").visible = false
	find_child("Spacer").visible = true

	find_child("PaginationContainer").visible = true
	find_child("WidgetContentAnchor").visible = false
		
	if pages.size() == 1:
		SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_PAGE, pages[0].id)


####################################################################################################
# Creates the widget navigation buttons.
####################################################################################################
func _update_widget_nav(widgetsInput: Array[Widget]):
	widgets = widgetsInput

	var fontSize = _compute_font_size(widgets)
	var content: Array[Object] = []

	for widget in widgets:
		if !(widget is PageTitleWidget):
			var cardSceneInstance = sectionCardScene.instantiate()
			cardSceneInstance.initialize(widget, fontSize)
			content.push_back(cardSceneInstance)
			pass

	find_child("PaginationContainer").set_content(content)
	
	if pages.size() > 1:
		find_child("QuitButton").visible = false
		find_child("WidgetBackButton").visible = true
	else:
		find_child("QuitButton").visible = true
		find_child("WidgetBackButton").visible = false

	find_child("WidgetContentBackButton").visible = false

	find_child("PaginationContainer").visible = true
	find_child("WidgetContentAnchor").visible = false


func _update_widget_content(widgetSceneData: WidgetSceneData) -> void:
	if widgetSceneData.primaryPanelScene:
		var widgetScene: Resource = load(widgetSceneData.primaryPanelScene)
		widgetContentSceneInstance = widgetScene.instantiate()
		widgetContentSceneInstance.initialize(widgetSceneData.widget)
				
		find_child("QuitButton").visible = false
		find_child("WidgetBackButton").visible = false
		find_child("WidgetContentBackButton").visible = true
		find_child("PaginationContainer").visible = false
		
		var widgetContentAnchor = find_child("WidgetContentAnchor")
		widgetContentAnchor.add_child(widgetContentSceneInstance)
		widgetContentAnchor.visible = true
	

func _on_widget_back_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.CTRL_PLAY_CLICK)
	_update_page_nav(pages)
	SignalBus.trigger(SignalBus.SignalType.COLL_CLOSE_WIDGET)


func _on_widget_content_back_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.CTRL_PLAY_CLICK)
	find_child("WidgetContentAnchor").remove_child(widgetContentSceneInstance)
	widgetContentSceneInstance.queue_free()
	_update_widget_nav(widgets)
	SignalBus.trigger(SignalBus.SignalType.COLL_CLOSE_WIDGET)


func _on_quit_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.CTRL_PLAY_CLICK)
	SignalBus.trigger(SignalBus.SignalType.COLL_QUIT_COLLECTION)


func _compute_font_size(content) -> int:
	var fontSize = 64
	if content.size() >= 6:
		fontSize = 48
	elif content.size() >= 9:
		fontSize = 24
	return fontSize


func _on_pause_voice_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.COLL_PAUSE_VOICE)
	pause_voice_button.visible = false
	resume_voice_button.visible = true


func _on_resume_voice_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.COLL_RESUME_VOICE)
	pause_voice_button.visible = true
	resume_voice_button.visible = false
