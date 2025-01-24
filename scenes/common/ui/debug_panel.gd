extends Control


func _init() -> void:
	SignalBus.register(SignalBus.SignalType.DEBUG, _update_debug_label)


func _update_debug_label(input: Variant) -> void:
	find_child("DebugLabel").text = input
