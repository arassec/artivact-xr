extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var arMode = SettingsStore.get_value(SettingsStore.SettingType.AR_MODE)
	if arMode:
		find_child("PassthroughButton").toggleState = false
	else:
		find_child("PassthroughButton").toggleState = true




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
