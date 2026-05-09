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
		# The tablet has been moved before and does not have to be repositioned again!
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
		var left_mode = HandTrackingUtil.get_tracking_type_for_hand(true)
		if left_mode == HandTrackingUtil.TrackingType.CONTROLLER:
			find_child("GrabPointHandLeft").rotate_x(deg_to_rad(-44))
			
		var right_mode = HandTrackingUtil.get_tracking_type_for_hand(false)
		if right_mode == HandTrackingUtil.TrackingType.CONTROLLER:
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
