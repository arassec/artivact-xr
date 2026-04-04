extends Node3D


## The composition layer whose surface is used for hit-testing.
@export var composition_layer: OpenXRCompositionLayerQuad


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var arMode = SettingsStore.get_value(SettingsStore.SettingType.AR_MODE)
	if arMode:
		find_child("PassthroughButton").toggleState = false
	else:
		find_child("PassthroughButton").toggleState = true




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if composition_layer != null:
		composition_layer.global_position = $PickableObject.global_position
		composition_layer.global_rotation = $PickableObject.global_rotation
