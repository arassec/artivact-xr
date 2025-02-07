extends Node3D


@onready var environment: Environment = $WorldEnvironment.environment

var environmentSceneInstance


####################################################################################################
# Initializes the script:
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.MAIN_SETTING_CHANGED, _setting_changed)
	

####################################################################################################
# Cleans up signal registrations after the scene closed.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.MAIN_SETTING_CHANGED, _setting_changed)
			

####################################################################################################
# Cleans up signal registrations after the scene closed.
####################################################################################################
func _ready() -> void:
	var arMode = SettingsStore.get_value(SettingsStore.SettingType.AR_MODE)
	if arMode:
		_switch_to_ar()
	else:
		_switch_to_vr()	


####################################################################################################
# Reacts on setting changes.
####################################################################################################
func _setting_changed(setting: Dictionary) -> void:
	if setting.has(str(SettingsStore.SettingType.AR_MODE)):
		var arMode = setting[str(SettingsStore.SettingType.AR_MODE)]
		if arMode:
			_switch_to_ar()
		else:
			_switch_to_vr()


####################################################################################################
# Switches to AR mode.
####################################################################################################
func _switch_to_ar() -> bool:
	var viewport = get_viewport()
	var xr_interface: XRInterface = XRServer.primary_interface
	if xr_interface:
		var modes = xr_interface.get_supported_environment_blend_modes()
		if XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND in modes:
			xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND
			viewport.transparent_bg = true
		elif XRInterface.XR_ENV_BLEND_MODE_ADDITIVE in modes:
			xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ADDITIVE
			viewport.transparent_bg = false
	else:
		return false

	_remove_environment()

	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.0, 0.0, 0.0, 0.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	return true


####################################################################################################
# Switches to VR mode.
####################################################################################################
func _switch_to_vr() -> bool:
	var viewport = get_viewport()
	var xr_interface: XRInterface = XRServer.primary_interface
	if xr_interface:
		var modes = xr_interface.get_supported_environment_blend_modes()
		if XRInterface.XR_ENV_BLEND_MODE_OPAQUE in modes:
			xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_OPAQUE
		else:
			return false

	_load_environment()

	viewport.transparent_bg = false
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_BG
	return true
	

####################################################################################################
# Loads the background environment scene.
####################################################################################################
func _load_environment() -> void:
	if !environmentSceneInstance:
		var environmentScene = load("res://scenes/common/environment/default/default_environment.tscn")
		if environmentScene != null:
			environmentSceneInstance = environmentScene.instantiate()
			add_child(environmentSceneInstance)

	if environmentSceneInstance:
		environmentSceneInstance.visible = true
		

####################################################################################################
# Loads the background environment scene.
####################################################################################################
func _remove_environment() -> void:
	if environmentSceneInstance:
		environmentSceneInstance.visible = false
