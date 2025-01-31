extends Control

var itemSearchDataScene: Resource = load("res://scenes/collection/widgets/item_search/item_search_data.tscn")

var widget: ItemSearchWidget

var items: Array[ArtivactItem] = []
var currentItemIndex

var paginationContent: Array[Object] = []


func initialize(widgetInput: ItemSearchWidget):
	if widgetInput == null:
		return
		
	widget = widgetInput
	var json = CollectionStore.read_json_file(str(widget.id, ".artivact.search-result.json"))

	
	for itemId in json.values:
		var artivactItem = ArtivactItem.new(CollectionStore.read_json_file(str(itemId, "/", "artivact.item.json")))
		items.append(artivactItem)
		
		var itemSearchDataSceneInstance = itemSearchDataScene.instantiate()
		itemSearchDataSceneInstance.initialize(artivactItem)
		paginationContent.push_back(itemSearchDataSceneInstance)

	var paginationContainer = find_child("PaginationContainer")
	if paginationContainer && paginationContent.size() > 0:
		paginationContainer.set_content(paginationContent)

	SignalBus.debug("AAA")

	if items.size() > 0:
		currentItemIndex = 0
		SignalBus.debug("BBB")
		SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_ITEM_MEDIA, items[currentItemIndex])
		SignalBus.debug("CCC")


####################################################################################################
# Move the cursor on input events.
####################################################################################################
func _input(event):
	if event is InputEventMouseMotion:
		# Move our cursor
		var mouse_motion : InputEventMouseMotion = event
		$Cursor.position = mouse_motion.position - Vector2(20, 20)


func _on_pagination_container_before_clicked() -> void:
	currentItemIndex -= 1
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_ITEM_MEDIA, items[currentItemIndex])


func _on_pagination_container_next_clicked() -> void:
	currentItemIndex += 1
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_ITEM_MEDIA, items[currentItemIndex])
