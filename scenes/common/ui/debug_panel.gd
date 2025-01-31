extends Control


####################################################################################################
# Registers for signals.
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.DEBUG, _update_debug_label)


####################################################################################################
# Deregisters from signals.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.DEBUG, _update_debug_label)


####################################################################################################
# Updates the debug label.
####################################################################################################
func _update_debug_label(input: Variant) -> void:
	find_child("DebugLabel").text = str(input)
