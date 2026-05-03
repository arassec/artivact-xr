extends Node

var appSettingsFile = "res://artivact-app-settings.json"
var userSettingsFile = "user://artivact-user-settings.json"

enum EnvironmentType {
	PASSTHROUGH,
	WORKSHOP
}

enum SettingType {
	# APP SETTINGS:
	API_URL,
	SHOW_WELCOME_PAGE,
	SHOW_ABOUT_PAGE,
	
	# USER SETTINGS:
	MUSIC_ENABLED = 100,
	MUSIC_VOLUME,
	ACTIVE_HAND, # DEPRECATED: value of 'true' means 'right hand'
	AR_MODE, # DEPRECATED: value of 'true' means 'AR', 'false' means 'VR'
	FIRST_START,
	LOCALE, # 0 == en, 1 == de
	VOICE_ENABLED,
	VOICE_VOLUME,
	ENVIRONMENT
}

var appSettings: Dictionary
var userSettings: Dictionary

var tabletTransform: Transform3D
var tabletPickedUp: bool = false


func _init():
	if FileAccess.file_exists(appSettingsFile):
		appSettings = JSON.parse_string(FileAccess.get_file_as_string(appSettingsFile))
	else:
		appSettings = {}
	
	if FileAccess.file_exists(userSettingsFile):
		userSettings = JSON.parse_string(FileAccess.get_file_as_string(userSettingsFile))
	else:
		userSettings = {}
	
	if !userSettings.has(str(SettingType.MUSIC_ENABLED)):
		userSettings[str(SettingType.MUSIC_ENABLED)] = true
	if !userSettings.has(str(SettingType.MUSIC_VOLUME)):
		userSettings[str(SettingType.MUSIC_VOLUME)] = 0.2
	if !userSettings.has(str(SettingType.FIRST_START)):
		userSettings[str(SettingType.FIRST_START)] = true
	if !userSettings.has(str(SettingType.LOCALE)):
		if TranslationServer.get_locale() == 'en':
			userSettings[str(SettingType.LOCALE)] = 0
		elif TranslationServer.get_locale() == 'de':
			userSettings[str(SettingType.LOCALE)] = 1
		else:
			userSettings[str(SettingType.LOCALE)] = -1
	if !userSettings.has(str(SettingType.VOICE_ENABLED)):
		userSettings[str(SettingType.VOICE_ENABLED)] = true
	if !userSettings.has(str(SettingType.VOICE_VOLUME)):
		userSettings[str(SettingType.VOICE_VOLUME)] = 0.4
	if !userSettings.has(str(SettingType.ENVIRONMENT)):
		userSettings[str(SettingType.ENVIRONMENT)] = EnvironmentType.WORKSHOP

	_save_user_settings()
	
	print("App-Settings: ", appSettings)
	print("User-Settings: ", userSettings)
	
	

func set_value(setting: SettingType, value: Variant) -> void:
	userSettings[str(setting)] = value
	_save_user_settings()


func get_value(setting: SettingType) -> Variant:
	if userSettings.has(str(setting)):
		return userSettings[str(setting)]
	
	if SettingType.API_URL == setting && appSettings.has('apiUrl'):
		return appSettings['apiUrl']
	elif SettingType.SHOW_WELCOME_PAGE == setting && appSettings.has('showWelcomePage'):
		return appSettings['showWelcomePage']
	elif SettingType.SHOW_ABOUT_PAGE == setting && appSettings.has('showAboutPage'):
		return appSettings['showAboutPage']
	
	return null


func get_locale() -> String:
	if userSettings.has(str(SettingType.LOCALE)):
		var configuredLocale = userSettings[str(SettingType.LOCALE)]
		if configuredLocale == 1:
			return "de"
	return ""


func _save_user_settings() -> void:
	var file_access := FileAccess.open(userSettingsFile, FileAccess.WRITE)
	if not file_access:
		print("Could not save user userSettings: ", FileAccess.get_open_error())
		return

	file_access.store_line(JSON.stringify(userSettings))
	file_access.close()


func set_tablet_picked_up(pickedUp: bool) -> void:
	tabletPickedUp = pickedUp


func is_tablet_picked_up() -> bool:
	return tabletPickedUp
	

func set_tablet_transform(transform: Transform3D) -> void:
	tabletTransform = transform


func get_tablet_transform():
	return tabletTransform
