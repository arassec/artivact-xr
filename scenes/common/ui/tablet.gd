extends Node3D


@export var composition_layer: OpenXRCompositionLayerQuad

var initialize := true


func _init():
	SignalBus.register(SignalBus.SignalType.COMMON_TOGGLE_AR_VR, _toggle_ar_vr)


func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.COMMON_TOGGLE_AR_VR, _toggle_ar_vr)


func _ready() -> void:
	var arMode = SettingsStore.get_value(SettingsStore.SettingType.AR_MODE)
	$PickableObject/Tablet.visible = !arMode

	if SettingsStore.get_tablet_transform() != null:
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
		
	if composition_layer != null:
		composition_layer.global_transform = $PickableObject/CompositionAnchor.global_transform


func _toggle_ar_vr(ar_mode: bool) -> void:
	$PickableObject/Tablet.visible = !ar_mode


func _on_pickable_object_dropped(_pickable: Variant) -> void:
	SettingsStore.set_tablet_transform($PickableObject.global_transform)
