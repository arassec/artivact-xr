extends Node

var settingsFile = "user://artivact-user-settings.json"

enum SettingType {
	MUSIC_ENABLED,
	MUSIC_VOLUME,
	ACTIVE_HAND, # value of 'true' means 'right hand'
	AR_MODE, # value of 'true' means 'AR', 'false' means 'VR'
}

var settings: Dictionary


func _init():
	if FileAccess.file_exists(settingsFile):
		var file_access := FileAccess.open(settingsFile, FileAccess.READ)
		var json_string := file_access.get_line()
		file_access.close()

		var json := JSON.new()
		var error := json.parse(json_string)
		if error:
			print("Could not parse settings file: ", json.get_error_message())
			return

		settings = json.data
	else:
		settings = {}
	
	if !settings.has(str(SettingType.MUSIC_ENABLED)):
		settings[str(SettingType.MUSIC_ENABLED)] = true
	if !settings.has(str(SettingType.MUSIC_VOLUME)):
		settings[str(SettingType.MUSIC_VOLUME)] = 0.2
	if !settings.has(str(SettingType.ACTIVE_HAND)):
		settings[str(SettingType.ACTIVE_HAND)] = true
	if !settings.has(str(SettingType.AR_MODE)):
		settings[str(SettingType.AR_MODE)] = false

	_save_settings()
	
	print("Settings: ", settings)
	
	

func set_value(setting: SettingType, value: Variant) -> void:
	settings[str(setting)] = value
	_save_settings()


func get_value(setting: SettingType) -> Variant:
	if settings.has(str(setting)):
		return settings[str(setting)]
	return null


func _save_settings() -> void:
	var file_access := FileAccess.open(settingsFile, FileAccess.WRITE)
	if not file_access:
		print("Could not save user settings: ", FileAccess.get_open_error())
		return

	file_access.store_line(JSON.stringify(settings))
	file_access.close()
