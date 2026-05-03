extends Node3D
class_name Tablet

@export var composition_layer: OpenXRCompositionLayerQuad

var initialize := true



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
# Perpares the tablet for rendering
####################################################################################################
func _ready() -> void:
	var environmentSetting = SettingsStore.get_value(SettingsStore.SettingType.ENVIRONMENT)
	if environmentSetting == SettingsStore.EnvironmentType.PASSTHROUGH:
		_toggle_tablet_base_visible(false)
	else:
		_toggle_tablet_base_visible(true)

	if SettingsStore.get_tablet_transform():
		$PickableObject.global_transform = SettingsStore.get_tablet_transform()
		initialize = false
		


func _process(_delta: float) -> void:
	if initialize:
		initialize = false
		# Orient the tablet's height on the XR camera's height:
		var cam = get_parent().find_child("XRCamera3D")
		if cam:
			transform.origin.y = (cam.transform.origin.y - 0.35)
			SettingsStore.set_tablet_transform($PickableObject.global_transform)
			
		# Rotate the grab points if controllers are used:
		var left_mode = get_input_mode_for_hand(true)
		if left_mode == "controller":
			find_child("GrabPointHandLeft").rotate_x(deg_to_rad(-44))
			
		var right_mode = get_input_mode_for_hand(false)
		if right_mode == "controller":
			find_child("GrabPointHandRight").rotate_x(deg_to_rad(-44))

	# Copy the XRCompositionLayer's transform to the tablet's to keep them in sync:
	if composition_layer != null:
		composition_layer.global_transform = $PickableObject/CompositionAnchor.global_transform



####################################################################################################
# Reacts on setting changes.
####################################################################################################
func _setting_changed(setting: Dictionary) -> void:
	if setting.has(str(SettingsStore.SettingType.ENVIRONMENT)):
		var environmentSetting = SettingsStore.get_value(SettingsStore.SettingType.ENVIRONMENT)
		if environmentSetting == SettingsStore.EnvironmentType.PASSTHROUGH:
			_toggle_tablet_base_visible(false)
		else:
			_toggle_tablet_base_visible(true)


func _toggle_tablet_base_visible(visible: bool) -> void:
	$PickableObject/Tablet.visible = visible


func play_click() -> void:
	$AudioStreamPlayer.play()
	

func get_global_pos() -> Vector3:
	return $PickableObject.global_position


func _on_pickable_object_dropped(_pickable: Variant) -> void:
	SettingsStore.set_tablet_picked_up(false)
	SettingsStore.set_tablet_transform($PickableObject.global_transform)


func _on_pickable_object_grabbed(_pickable: Variant, _by: Variant) -> void:
	SettingsStore.set_tablet_picked_up(true)


func get_input_mode_for_hand(is_left: bool) -> String:
	var tracker_path := "/user/hand_tracker/left" if is_left else "/user/hand_tracker/right"
	var hand_tracker: XRHandTracker = XRServer.get_tracker(tracker_path)

	if hand_tracker == null:
		return "no_hand_tracking_support"

	if not hand_tracker.has_tracking_data:
		return "controller_or_not_tracked"

	match hand_tracker.hand_tracking_source:
		XRHandTracker.HAND_TRACKING_SOURCE_UNOBSTRUCTED:
			return "hand_tracking" 
		XRHandTracker.HAND_TRACKING_SOURCE_CONTROLLER:
			return "controller"  
		_:
			return "unknown"
