extends Node3D

# Contains basic collection information for the main menu:
var collectionInfos: Array[CollectionInfo] = []
var currentCollectionInfo: int = -1

# Contains the collection ZIP readers, indexed by the collection's ID.
#    Collection ID -> ZIP Reader of the collection's ZIP file on disk
var collectionZipReaders: Dictionary = {}

# Contains the parsed content export JSON file, indexed by the collection's ID.
#    Collection ID -> ArtivactContentJson
var artivactContentJsons: Dictionary = {}


func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.EXIT_APPLICATION, exit_application)
	SignalBus.register(SignalBus.SignalType.NEXT_COLLECTION_INFO, next_collection_info)
	SignalBus.register(SignalBus.SignalType.PREVIOUS_COLLECTION_INFO, previous_collection_info)
	SignalBus.register(SignalBus.SignalType.OPEN_COLLECTION, open_collection)

	# Collect collection information from disk:
	load_collections()


func _ready():
	# Initialize Godot XR stuff:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	get_viewport().msaa_3d = Viewport.MSAA_4X


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if currentCollectionInfo == -1 && collectionInfos.size() > 0:
		currentCollectionInfo = 0
		SignalBus.trigger_with_payload(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, collectionInfos[currentCollectionInfo])


# Fallback keyboard shortcuts to test the application without XR device.
func _input(event):
	if event is InputEventKey && !event.pressed && event.keycode == Key.KEY_O:
		SignalBus.trigger(SignalBus.SignalType.OPEN_COLLECTION)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_E:
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_P:
		SignalBus.trigger(SignalBus.SignalType.PREVIOUS_COLLECTION_INFO)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_N:
		SignalBus.trigger(SignalBus.SignalType.NEXT_COLLECTION_INFO)
	elif event is InputEventKey && !event.pressed && event.keycode == Key.KEY_Q:
		SignalBus.trigger(SignalBus.SignalType.NEXT_COLLECTION_INFO)


func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.EXIT_APPLICATION, exit_application)
	SignalBus.deregister(SignalBus.SignalType.NEXT_COLLECTION_INFO, next_collection_info)
	SignalBus.deregister(SignalBus.SignalType.PREVIOUS_COLLECTION_INFO, previous_collection_info)
	SignalBus.deregister(SignalBus.SignalType.OPEN_COLLECTION, open_collection)


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit() # default behavior


func exit_application():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	

func load_collections():
	var resourceFiles = DirAccess.get_files_at("res://")
	for resourceFile in resourceFiles:
		if resourceFile.ends_with(".artivact.content.json.zip"):
			load_collection(resourceFile)


func load_collection(collectionFile: String):
	var collectionId = collectionFile.replace(".artivact.content.json.zip", "")
	var collectionZipFile = str("res://", collectionFile)
	var collectionJsonFile = "artivact.content.json"
	
	var zipReader = ZIPReader.new()
	var openResult := zipReader.open(collectionZipFile)
	if openResult != OK:
		# TODO: Error handling!
		return
	
	var collectionJson := JSON.new()
	var collectionJsonString = zipReader.read_file(collectionJsonFile).get_string_from_utf8()
	var parseResult := collectionJson.parse(collectionJsonString)
	if parseResult != OK:
		# TODO: Error handling!
		return

	var collectionData = collectionJson.data

	# Save the parsed content JSON containing properties and tags:	
	artivactContentJsons[collectionId] = ArtivactContentJson.new(collectionData)
	
	# Save the ZIP reader for the collection file:
	collectionZipReaders[collectionId] = zipReader
	
	# Create collcetion info for the main menu:
	var lastModified = FileAccess.get_modified_time(collectionZipFile)
	var file := FileAccess.open(collectionZipFile, FileAccess.READ)
	var fileSize = file.get_length()
	collectionInfos.append(CollectionInfo.new(collectionId, artivactContentJsons[collectionId], lastModified, fileSize))


func next_collection_info():
	if currentCollectionInfo < (collectionInfos.size() -1):
		currentCollectionInfo = currentCollectionInfo + 1
		SignalBus.trigger_with_payload(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, collectionInfos[currentCollectionInfo])


func previous_collection_info():
	if currentCollectionInfo > 0:
		currentCollectionInfo = currentCollectionInfo -1
		SignalBus.trigger_with_payload(SignalBus.SignalType.UPDATE_SELECTED_COLLECTION, collectionInfos[currentCollectionInfo])


func open_collection():
	# Find the XRToolsSceneBase ancestor of the current node
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		return
	# Request loading the next scene
	scene_base.load_scene("res://scenes/collection/collection_main.tscn")
