####################################################################################################
# collection_main.gd
#
# Main script for the collection scene. This is the base scene for the "in-collection" experience.
####################################################################################################
extends Node


####################################################################################################
# Registers for signals.
####################################################################################################
func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.QUIT_COLLECTION, quit_collection)
	
	
####################################################################################################
# TODO
####################################################################################################
func _ready():
	pass # Replace with function body.


####################################################################################################
# TODO
####################################################################################################
func _process(delta):
	pass


####################################################################################################
# Creates fallback key handling to support testing the application without headset.
####################################################################################################
func _input(event):
	if event is InputEventKey && !event.pressed && event.keycode == Key.KEY_Q:
		SignalBus.trigger(SignalBus.SignalType.QUIT_COLLECTION)


####################################################################################################
# Deregisters from signals.
####################################################################################################
func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.QUIT_COLLECTION, quit_collection)
	
	
####################################################################################################
# Quits the collection and transits to Artivact XR's main scene.
####################################################################################################
func quit_collection():
			# Find the XRToolsSceneBase ancestor of the current node
		var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
		if not scene_base:
			return
		# Request loading the next scene
		scene_base.exit_to_main_menu()
