extends Node


func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.QUIT_COLLECTION, quit_collection)
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if event is InputEventKey && !event.pressed && event.keycode == Key.KEY_Q:
		SignalBus.trigger(SignalBus.SignalType.QUIT_COLLECTION)


func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.QUIT_COLLECTION, quit_collection)
	
	
func quit_collection():
			# Find the XRToolsSceneBase ancestor of the current node
		var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
		if not scene_base:
			return
		# Request loading the next scene
		scene_base.exit_to_main_menu()
