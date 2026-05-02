extends Control

var cardScene: Resource = load("res://scenes/main/ui/collection_card.tscn")

var initialized: bool = false


func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.MAIN_COLLECTION_INFOS_UPDATED, _collection_infos_updated)
	SignalBus.register(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION, _download_collection)
	SignalBus.register(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION_PROGRESS, _download_collection_progress)
	SignalBus.register(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION_FINISHED, _clear_operation_in_progress)


func _exit_tree():
	# Deregister signals:
	SignalBus.deregister(SignalBus.SignalType.MAIN_COLLECTION_INFOS_UPDATED, _collection_infos_updated)
	SignalBus.deregister(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION, _download_collection)
	SignalBus.deregister(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION_PROGRESS, _download_collection_progress)
	SignalBus.deregister(SignalBus.SignalType.MAIN_DOWNLOAD_COLLECTION_FINISHED, _clear_operation_in_progress)


func _ready():
	# Set project version in "About"-Panel
	$AboutPanel/MarginContainer/VBoxContainer/AboutMenu/VersionLabel.text = str('v', ProjectSettings.get_setting("application/config/version"))
	
	# Set API-URL in "NoContentAvailable"-Panel:
	find_child("ApiUrlLabel").text = str('( ', SettingsStore.get_value(SettingsStore.SettingType.API_URL), ' )')
	
	var arMode = SettingsStore.get_value(SettingsStore.SettingType.AR_MODE)
	if arMode:
		find_child("PassthroughModeButton").visible = false
		find_child("ImmersiveModeButton").visible = true
	else:
		find_child("PassthroughModeButton").visible = true
		find_child("ImmersiveModeButton").visible = false

	if !initialized:
		initialized = true
		if CollectionStore.collectionInfos.size() > 0:
			_collection_infos_updated()

	find_child("MusicEnabledCheckBox").button_pressed = SettingsStore.get_value(SettingsStore.SettingType.MUSIC_ENABLED)
	find_child("MusicVolumeHSlider").value = SettingsStore.get_value(SettingsStore.SettingType.MUSIC_VOLUME)

	find_child("VoiceEnabledCheckBox").button_pressed = SettingsStore.get_value(SettingsStore.SettingType.VOICE_ENABLED)
	find_child("VoiceVolumeHSlider").value = SettingsStore.get_value(SettingsStore.SettingType.VOICE_VOLUME)

	var firstStart = SettingsStore.get_value(SettingsStore.SettingType.FIRST_START)
	var showWelcomePage = SettingsStore.get_value(SettingsStore.SettingType.SHOW_WELCOME_PAGE)
	if firstStart:
		SettingsStore.set_value(SettingsStore.SettingType.FIRST_START, false)
		if showWelcomePage:
			$WelcomePanel.visible = true

	var showAboutPage = SettingsStore.get_value(SettingsStore.SettingType.SHOW_ABOUT_PAGE)
	if !showAboutPage:
		find_child("AboutButton").visible = false

	var locale = SettingsStore.get_value(SettingsStore.SettingType.LOCALE)
	if locale == 0:
		find_child("EnCheckButton").button_pressed = true
		find_child("EnCheckButton").disabled = true
		find_child("DeCheckButton").button_pressed = false
		find_child("DeCheckButton").disabled = false
	elif locale == 1:
		find_child("EnCheckButton").button_pressed = false
		find_child("EnCheckButton").disabled = false
		find_child("DeCheckButton").button_pressed = true
		find_child("DeCheckButton").disabled = true


func _collection_infos_updated() -> void:
	_clear_operation_in_progress()
	
	var content: Array[Object] = []
	var collectionInfos: Array[CollectionInfo] = CollectionStore.collectionInfos
	
	var fontSize = 96
	if collectionInfos.size() >= 9:
		$CollectionContainer/CollectionPaginationContainer.pageSize = 9
		$CollectionContainer/CollectionPaginationContainer.columns = 3
		fontSize = 32
	elif collectionInfos.size() >= 4:
		$CollectionContainer/CollectionPaginationContainer.pageSize = 4
		$CollectionContainer/CollectionPaginationContainer.columns = 2
		fontSize = 64
		
	for collectionInfo in collectionInfos:
		var cardSceneInstance = cardScene.instantiate()
		cardSceneInstance.initialize(collectionInfo, fontSize)
		content.push_back(cardSceneInstance)
		
	$CollectionContainer/MarginContainer/VBoxContainer/MarginContainer/CollectionPaginationContainer.set_content(content)


func _on_quit_button_pressed() -> void:
	SignalBus.trigger(SignalBus.SignalType.MAIN_EXIT_APPLICATION)


func _download_collection(_collectionId: String):
	find_child("StatusLabel").text = tr("MAIN_DOWNLOADING")
	find_child("OperationInProgressCover").visible = true


func _download_collection_progress(progress: int):
	find_child("StatusLabel").text = str(tr("MAIN_DOWNLOADING"), ' ', progress, '%')


func _clear_operation_in_progress():
	find_child("OperationInProgressCover").visible = false
	find_child("StatusLabel").text = ''


func _on_settings_button_pressed() -> void:
	$SettingsPanel.visible = true


func _on_settings_back_button_pressed() -> void:
	$SettingsPanel.visible = false
	

func _on_about_button_pressed() -> void:
	$AboutPanel.visible = true


func _on_about_back_button_pressed() -> void:
	$AboutPanel.visible = false


func _on_welcome_back_button_pressed() -> void:
	$WelcomePanel.visible = false


func _on_en_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		SettingsStore.set_value(SettingsStore.SettingType.LOCALE, 0)
		TranslationServer.set_locale('en')
		find_child("EnCheckButton").button_pressed = true
		find_child("EnCheckButton").disabled = true
		find_child("DeCheckButton").button_pressed = false
		find_child("DeCheckButton").disabled = false
		SignalBus.trigger_with_payload(SignalBus.SignalType.MAIN_SETTING_CHANGED, {str(SettingsStore.SettingType.LOCALE): 0})


func _on_de_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		SettingsStore.set_value(SettingsStore.SettingType.LOCALE, 1)
		TranslationServer.set_locale('de')
		find_child("EnCheckButton").button_pressed = false
		find_child("EnCheckButton").disabled = false
		find_child("DeCheckButton").button_pressed = true
		find_child("DeCheckButton").disabled = true
		SignalBus.trigger_with_payload(SignalBus.SignalType.MAIN_SETTING_CHANGED, {str(SettingsStore.SettingType.LOCALE): 1})


func _on_music_enabled_check_box_toggled(toggled_on: bool) -> void:
	SettingsStore.set_value(SettingsStore.SettingType.MUSIC_ENABLED, toggled_on)
	SignalBus.trigger_with_payload(SignalBus.SignalType.MAIN_SETTING_CHANGED, {str(SettingsStore.SettingType.MUSIC_ENABLED): toggled_on})


func _on_music_volume_h_slider_value_changed(value: float) -> void:
	SettingsStore.set_value(SettingsStore.SettingType.MUSIC_VOLUME, value)
	SignalBus.trigger_with_payload(SignalBus.SignalType.MAIN_SETTING_CHANGED, {str(SettingsStore.SettingType.MUSIC_VOLUME): value})


func _on_passthrough_mode_button_pressed() -> void:
	SignalBus.trigger_with_payload(SignalBus.SignalType.COMMON_TOGGLE_AR_VR, true)
	find_child("PassthroughModeButton").visible = false
	find_child("ImmersiveModeButton").visible = true


func _on_immersive_mode_button_pressed() -> void:
	SignalBus.trigger_with_payload(SignalBus.SignalType.COMMON_TOGGLE_AR_VR, false)
	find_child("PassthroughModeButton").visible = true
	find_child("ImmersiveModeButton").visible = false


func _on_voice_enabled_check_box_toggled(toggled_on: bool) -> void:
	SettingsStore.set_value(SettingsStore.SettingType.VOICE_ENABLED, toggled_on)
	SignalBus.trigger_with_payload(SignalBus.SignalType.MAIN_SETTING_CHANGED, {str(SettingsStore.SettingType.VOICE_ENABLED): toggled_on})


func _on_voice_volume_h_slider_value_changed(value: float) -> void:
	SettingsStore.set_value(SettingsStore.SettingType.VOICE_VOLUME, value)
	SignalBus.trigger_with_payload(SignalBus.SignalType.MAIN_SETTING_CHANGED, {str(SettingsStore.SettingType.VOICE_VOLUME): value})
