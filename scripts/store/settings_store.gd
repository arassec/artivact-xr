extends Node

var appSettingsFile = "res://artivact-app-settings.json"
var userSettingsFile = "user://artivact-user-settings.json"

enum SettingType {
	# APP SETTINGS:
	API_URL,
	SHOW_WELCOME_PAGE,
	SHOW_ABOUT_PAGE,
	
	# USER SETTINGS:
	MUSIC_ENABLED = 100,
	MUSIC_VOLUME,
	ACTIVE_HAND, # value of 'true' means 'right hand'
	AR_MODE, # value of 'true' means 'AR', 'false' means 'VR'
	FIRST_START,
	LOCALE # 0 == en, 1 == de
}

var appSettings: Dictionary
var userSettings: Dictionary


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
	if !userSettings.has(str(SettingType.ACTIVE_HAND)):
		userSettings[str(SettingType.ACTIVE_HAND)] = true
	if !userSettings.has(str(SettingType.AR_MODE)):
		userSettings[str(SettingType.AR_MODE)] = false
	if !userSettings.has(str(SettingType.FIRST_START)):
		userSettings[str(SettingType.FIRST_START)] = true
	if !userSettings.has(str(SettingType.LOCALE)):
		if TranslationServer.get_locale() == 'en':
			userSettings[str(SettingType.LOCALE)] = 0
		elif TranslationServer.get_locale() == 'de':
			userSettings[str(SettingType.LOCALE)] = 1
		else:
			userSettings[str(SettingType.LOCALE)] = -1

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


func _save_user_settings() -> void:
	var file_access := FileAccess.open(userSettingsFile, FileAccess.WRITE)
	if not file_access:
		print("Could not save user userSettings: ", FileAccess.get_open_error())
		return

	file_access.store_line(JSON.stringify(userSettings))
	file_access.close()
