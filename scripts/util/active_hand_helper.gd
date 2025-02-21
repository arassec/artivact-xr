extends Node



# Called when the node enters the scene tree for the first time.
func _ready():
	var rightHandActive = SettingsStore.get_value(SettingsStore.SettingType.ACTIVE_HAND)
	$LeftHand.visible = !rightHandActive
	$RightHand.visible = rightHandActive


func _on_left_hand_button_pressed(name: String) -> void:
	if name == "trigger_click":
		
		if !SettingsStore.get_value(SettingsStore.SettingType.ACTIVE_HAND):
			return
		
		$LeftHand.visible = true
		$LeftHand.trigger_haptic_pulse("haptic", 0.0, 1.0, 0.5, 0.0)
		
		SettingsStore.set_value(SettingsStore.SettingType.ACTIVE_HAND, false)
		SignalBus.trigger_with_payload(SignalBus.SignalType.MAIN_SETTING_CHANGED, {str(SettingsStore.SettingType.ACTIVE_HAND): false})

		$RightHand.visible = false
		
	if name == "grip_click":
		SignalBus.trigger_with_payload(SignalBus.SignalType.CTRL_GRIP_PRESSED, $LeftHand)


func _on_right_hand_button_pressed(name: String) -> void:
	if name == "trigger_click":

		if SettingsStore.get_value(SettingsStore.SettingType.ACTIVE_HAND):
			return

		$RightHand.visible = true
		$RightHand.trigger_haptic_pulse("haptic", 0.0, 1.0, 0.5, 0.0)
		
		SettingsStore.set_value(SettingsStore.SettingType.ACTIVE_HAND, true)
		SignalBus.trigger_with_payload(SignalBus.SignalType.MAIN_SETTING_CHANGED, {str(SettingsStore.SettingType.ACTIVE_HAND): true})

		$LeftHand.visible = false

	if name == "grip_click":
		SignalBus.trigger_with_payload(SignalBus.SignalType.CTRL_GRIP_PRESSED, $RightHand)


func _on_left_hand_button_released(name: String) -> void:
	if name == "grip_click":
		SignalBus.trigger_with_payload(SignalBus.SignalType.CTRL_GRIP_RELEASED, $LeftHand)


func _on_right_hand_button_released(name: String) -> void:
	if name == "grip_click":
		SignalBus.trigger_with_payload(SignalBus.SignalType.CTRL_GRIP_RELEASED, $RightHand)
