extends Node3D


@export var initializeXrMode: bool = true
@onready var environment: Environment = $WorldEnvironment.environment

var environmentSceneInstance
var arMode: bool


####################################################################################################
# Initializes the script:
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.COMMON_TOGGLE_AR_VR, _toggle_ar_vr)
	

####################################################################################################
# Cleans up signal registrations after the scene closed.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.COMMON_TOGGLE_AR_VR, _toggle_ar_vr)
			

####################################################################################################
# Initializes the environment.
####################################################################################################
func _ready() -> void:
	arMode = SettingsStore.get_value(SettingsStore.SettingType.AR_MODE)
	if arMode:
		_switch_to_ar()
	else:
		_switch_to_vr()


####################################################################################################
# Toggles between AR und VR.
####################################################################################################
func _toggle_ar_vr(ar_mode: bool) -> void:
	SettingsStore.set_value(SettingsStore.SettingType.AR_MODE, ar_mode)
	SignalBus.trigger_with_payload(SignalBus.SignalType.MAIN_SETTING_CHANGED, {str(SettingsStore.SettingType.AR_MODE): false})
	if ar_mode:
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
