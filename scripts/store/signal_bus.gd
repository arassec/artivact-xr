extends Node


var debugLogSignals = false


enum SignalType {
	DEBUG,
	
	MAIN_EXIT_APPLICATION,
	MAIN_COLLECTION_INFOS_UPDATED,
	MAIN_DELETE_COLLECTION,
	MAIN_OPEN_COLLECTION,
	MAIN_DOWNLOAD_COLLECTION,
	MAIN_DOWNLOAD_COLLECTION_PROGRESS,
	MAIN_DOWNLOAD_COLLECTION_FINISHED,
	MAIN_SETTING_CHANGED,
	
	COLL_QUIT_COLLECTION,
	COLL_UPDATE_PAGE_NAV,
	COLL_OPEN_PAGE,
	COLL_UPDATE_WIDGET_NAV,
	COLL_OPEN_WIDGET,
	COLL_UPDATE_WIDGET_CONTENT,
	COLL_ITEM_NEXT,
	COLL_ITEM_PREVIOUS,
	COLL_OPEN_ITEM_MEDIA,
	COLL_CLOSE_ITEM_MEDIA,
	
	UPDATE_PAGE_NAVIGATION,
	OPEN_PAGE,
	UPDATE_WIDGET_NAVIGATION,
	OPEN_WIDGET,
	WIDGET_CONTENT_LOAD,
	WIDGET_CONTENT_CLEAR,
	WIDGET_NAVIGATION_MENU_SHOW,
	WIDGET_NAVIGATION_MENU_HIDE,
	WIDGET_NAVIGATION_MENU_UPDATE_PAGINATOR,
	WIDGET_NAVIGATION_MENU_NEXT,
	WIDGET_NAVIGATION_MENU_PREVIOUS,
	WIDGET_NAVIGATION_MENU_INFO,
	WIDGET_NAVIGATION_MENU_DATA,
}

var callbacks = {
	SignalType.DEBUG: [],
	
	SignalType.MAIN_EXIT_APPLICATION: [],
	SignalType.MAIN_COLLECTION_INFOS_UPDATED: [],
	SignalType.MAIN_OPEN_COLLECTION: [],
	SignalType.MAIN_DELETE_COLLECTION: [],
	SignalType.MAIN_DOWNLOAD_COLLECTION: [],
	SignalType.MAIN_DOWNLOAD_COLLECTION_PROGRESS: [],
	SignalType.MAIN_DOWNLOAD_COLLECTION_FINISHED: [],
	SignalType.MAIN_SETTING_CHANGED: [],

	SignalType.COLL_QUIT_COLLECTION: [],
	SignalType.COLL_OPEN_PAGE: [],
	SignalType.COLL_UPDATE_PAGE_NAV: [],
	SignalType.COLL_UPDATE_WIDGET_NAV: [],
	SignalType.COLL_OPEN_WIDGET: [],	
	SignalType.COLL_UPDATE_WIDGET_CONTENT: [],
	SignalType.COLL_ITEM_NEXT: [],
	SignalType.COLL_ITEM_PREVIOUS: [],
	SignalType.COLL_OPEN_ITEM_MEDIA: [],
	SignalType.COLL_CLOSE_ITEM_MEDIA: [],

	SignalType.UPDATE_PAGE_NAVIGATION: [],
	SignalType.OPEN_PAGE: [],
	SignalType.UPDATE_WIDGET_NAVIGATION: [],
	SignalType.OPEN_WIDGET: [],
	SignalType.WIDGET_CONTENT_LOAD: [],
	SignalType.WIDGET_CONTENT_CLEAR: [],
	SignalType.WIDGET_NAVIGATION_MENU_SHOW: [],
	SignalType.WIDGET_NAVIGATION_MENU_HIDE: [],
	SignalType.WIDGET_NAVIGATION_MENU_UPDATE_PAGINATOR: [],
	SignalType.WIDGET_NAVIGATION_MENU_NEXT: [],
	SignalType.WIDGET_NAVIGATION_MENU_PREVIOUS: [],
	SignalType.WIDGET_NAVIGATION_MENU_INFO: [],
	SignalType.WIDGET_NAVIGATION_MENU_DATA: [],
}


func register(type: SignalType, callback: Callable):
	callbacks[type].push_back(callback)


func deregister(type: SignalType, callback: Callable):
	callbacks[type].erase(callback)


func trigger(type: SignalType):
	if debugLogSignals:
		debug_json({"type": type})
	for callback in callbacks[type]:
		callback.call()


func trigger_with_payload(type: SignalType, payload: Variant):
	if debugLogSignals:
		debug_json({"type": type, "payload": payload})
	for callback in callbacks[type]:
		callback.call(payload)


func trigger_with_multiload(type: SignalType, payloadOne: Variant, payloadTwo: Variant):
	if debugLogSignals:
		debug_json({"type": type, "payloadOne": payloadOne, "payloadTwo": payloadTwo})
	for callback in callbacks[type]:
		callback.call(payloadOne, payloadTwo)


func trigger_with_node(type: SignalType, payload: Node):
	if debugLogSignals:
		debug_json({"type": type, "payload": payload})
	for callback in callbacks[type]:
		callback.call(payload)


func trigger_with_widget(type: SignalType, payload: Widget):
	if debugLogSignals:
		debug_json({"type": type, "payload": payload})
	for callback in callbacks[type]:
		callback.call(payload)


func debug(payload: String) -> void:
	for callback in callbacks[SignalType.DEBUG]:
		callback.call(payload)


func debug_json(payload: Dictionary):
	for callback in callbacks[SignalType.DEBUG]:
		callback.call(payload)
