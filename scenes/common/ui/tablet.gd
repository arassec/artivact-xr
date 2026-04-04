extends Node3D


# The composition layer whose surface is used for the tablet
@export var composition_layer: OpenXRCompositionLayerQuad


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
	var arMode = SettingsStore.get_value(SettingsStore.SettingType.AR_MODE)
	$PickableObject/Tablet.visible = !arMode


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if composition_layer != null:
		composition_layer.global_transform = $PickableObject/CompositionAnchor.global_transform


func _toggle_ar_vr(ar_mode: bool) -> void:
	$PickableObject/Tablet.visible = !ar_mode
