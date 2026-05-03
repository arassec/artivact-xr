extends Node3D


@export var initializeXrMode: bool = true
@onready var environment: Environment = $WorldEnvironment.environment

var environmentSceneInstance
var environmentSetting: SettingsStore.EnvironmentType


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
# Initializes the environment.
####################################################################################################
func _ready() -> void:
	environmentSetting = SettingsStore.get_value(SettingsStore.SettingType.ENVIRONMENT)
	_switch_environment(environmentSetting)


####################################################################################################
# Reacts on setting changes.
####################################################################################################
func _setting_changed(setting: Dictionary) -> void:
	if setting.has(str(SettingsStore.SettingType.ENVIRONMENT)):
		environmentSetting = SettingsStore.get_value(SettingsStore.SettingType.ENVIRONMENT)
		_switch_environment(environmentSetting)


####################################################################################################
# Toggles between AR und VR.
####################################################################################################
func _switch_environment(environmentInput: SettingsStore.EnvironmentType) -> void:
	if environmentInput == SettingsStore.EnvironmentType.PASSTHROUGH:
		_switch_to_ar()
	else:
		_switch_to_vr()


####################################################################################################
# Switches to AR mode.
####################################################################################################
func _switch_to_ar() -> bool:
	if initializeXrMode:
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

	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.0, 0.0, 0.0, 0.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR

	_remove_environment()

	return true


####################################################################################################
# Switches to VR mode.
####################################################################################################
func _switch_to_vr() -> bool:
	if initializeXrMode:
		var viewport = get_viewport()
		var xr_interface: XRInterface = XRServer.primary_interface
		if xr_interface:
			var modes = xr_interface.get_supported_environment_blend_modes()
			if XRInterface.XR_ENV_BLEND_MODE_OPAQUE in modes:
				xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_OPAQUE
			else:
				return false

		viewport.transparent_bg = false
		
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_BG

	_load_environment()

	return true


####################################################################################################
# Loads the background environment scene.
####################################################################################################
func _load_environment() -> void:
	if !environmentSceneInstance:
		# Here environmentScene should be checked. But for now, "Workshop" is currently the only 
		# environment besides passthrough, and the default anyway:
		var environmentScene = load("res://scenes/common/environment/workshop/workshop_environment.tscn")
		if environmentScene != null:
			environmentSceneInstance = environmentScene.instantiate()
			add_child(environmentSceneInstance)

	if environmentSceneInstance:
		environmentSceneInstance.visible = true

	var controller = get_tree().get_root().find_child("RightHandModel", true, false)
	if controller:
		controller.visible = true
	controller = get_tree().get_root().find_child("LeftHandModel", true, false)
	if controller:
		controller.visible = true
		

####################################################################################################
# Loads the background environment scene.
####################################################################################################
func _remove_environment() -> void:
	if environmentSceneInstance:
		environmentSceneInstance.visible = false
	
	var controller = get_tree().get_root().find_child("RightHandModel", true, false)
	if controller:
		controller.visible = false
	controller = get_tree().get_root().find_child("LeftHandModel", true, false)
	if controller:
		controller.visible = false
