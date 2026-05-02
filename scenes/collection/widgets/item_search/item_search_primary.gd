extends Control

var itemSearchDataScene: Resource = preload("res://scenes/collection/widgets/item_search/item_search_data.tscn")

var widget: ItemSearchWidget

var items: Array[ArtivactItem] = []

var currentItemIndex := 0

var paginationContent: Array[Object] = []


func initialize(widgetInput: ItemSearchWidget):

	if widgetInput == null:
		return
				
	widget = widgetInput
	
	var headingLabel = find_child("HeadingLabel")
	if headingLabel != null:
		headingLabel.text = widget.heading.translate()
		
	var contentLabel = find_child("ContentLabel")
	if contentLabel != null:
		contentLabel.text = widget.content.translate()

	var searchResultFile = PathUtil.get_default_file_path(ComponentType.WIDGET, widget.id)
	var json = CollectionStore.read_json_file(searchResultFile)

	for itemId in json.values:
		var artivactItemJsonFile = PathUtil.get_default_file_path(ComponentType.ITEM, itemId)
		var artivactItem = ArtivactItem.new(CollectionStore.read_json_file(artivactItemJsonFile))
		items.append(artivactItem)
		
		# TODO: Cleanup?!?
		var itemSearchDataSceneInstance = itemSearchDataScene.instantiate()
		itemSearchDataSceneInstance.initialize(artivactItem)
		paginationContent.push_back(itemSearchDataSceneInstance)
	
	var paginationContainer = find_child("PaginationContainer")
	if paginationContainer && paginationContent.size() > 0:
		paginationContainer.set_content(paginationContent)

	if items.size() > 0:
		currentItemIndex = 0
		SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_ITEM_MEDIA, items[currentItemIndex])


func _on_pagination_container_before_clicked() -> void:
	currentItemIndex -= 1
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_ITEM_MEDIA, items[currentItemIndex])


func _on_pagination_container_next_clicked() -> void:
	currentItemIndex += 1
	SignalBus.trigger_with_payload(SignalBus.SignalType.COLL_OPEN_ITEM_MEDIA, items[currentItemIndex])
