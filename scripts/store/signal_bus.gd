extends Node

enum SignalType {
	EXIT_APPLICATION,
	UPDATE_REMOTE_COLLECTION_INFOS,
	COLLECTION_INFOS_UPDATED,
	RELOAD_COLLECTION_INFOS,
	RELOAD_COLLECTION_INFOS_FINISHED,
	OPEN_SETTINGS,
	NEXT_COLLECTION_INFO,
	PREVIOUS_COLLECTION_INFO,
	UPDATE_SELECTED_COLLECTION,
	OPEN_COLLECTION,
	DOWNLOAD_COLLECTION,
	DOWNLOAD_COLLECTION_PROGRESS,
	DOWNLOAD_COLLECTION_FINISHED,
	DELETE_COLLECTION,
	
	COLL_QUIT_COLLECTION,
	COLL_UPDATE_PAGE_NAV,
	COLL_OPEN_PAGE,
	COLL_UPDATE_WIDGET_NAV,
	COLL_OPEN_WIDGET,
	COLL_UPDATE_WIDGET_CONTENT,
	COLL_ITEM_NEXT,
	COLL_ITEM_PREVIOUS,
	COLL_ITEM_UPDATE_PAGINATOR,
	COLL_ITEM_SHOW_INFO,
	COLL_ITEM_HIDE_INFO,
	COLL_ITEM_SHOW_DATA,
	COLL_ITEM_HIDE_DATA,
	COLL_ITEM_UPDATE_DATA,
	COLL_WIDGET_CONTENT_LEFT,
	COLL_WIDGET_CONTENT_CENTER,
	
	QUIT_COLLECTION,
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
	SignalType.EXIT_APPLICATION: [],
	SignalType.UPDATE_REMOTE_COLLECTION_INFOS: [],
	SignalType.COLLECTION_INFOS_UPDATED: [],
	SignalType.RELOAD_COLLECTION_INFOS: [],
	SignalType.RELOAD_COLLECTION_INFOS_FINISHED: [],
	SignalType.OPEN_SETTINGS: [],
	SignalType.NEXT_COLLECTION_INFO: [],
	SignalType.PREVIOUS_COLLECTION_INFO: [],
	SignalType.UPDATE_SELECTED_COLLECTION: [],
	SignalType.OPEN_COLLECTION: [],
	SignalType.DOWNLOAD_COLLECTION: [],
	SignalType.DOWNLOAD_COLLECTION_PROGRESS: [],
	SignalType.DOWNLOAD_COLLECTION_FINISHED: [],
	SignalType.DELETE_COLLECTION: [],

	SignalType.COLL_QUIT_COLLECTION: [],
	SignalType.COLL_OPEN_PAGE: [],
	SignalType.COLL_UPDATE_PAGE_NAV: [],
	SignalType.COLL_UPDATE_WIDGET_NAV: [],
	SignalType.COLL_OPEN_WIDGET: [],
	SignalType.COLL_UPDATE_WIDGET_CONTENT: [],
	SignalType.COLL_ITEM_NEXT: [],
	SignalType.COLL_ITEM_PREVIOUS: [],
	SignalType.COLL_ITEM_UPDATE_PAGINATOR: [],
	SignalType.COLL_ITEM_SHOW_INFO: [],
	SignalType.COLL_ITEM_HIDE_INFO: [],
	SignalType.COLL_ITEM_SHOW_DATA: [],
	SignalType.COLL_ITEM_HIDE_DATA: [],
	SignalType.COLL_ITEM_UPDATE_DATA: [],
	SignalType.COLL_WIDGET_CONTENT_LEFT: [],
	SignalType.COLL_WIDGET_CONTENT_CENTER: [],

	SignalType.QUIT_COLLECTION: [],
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
	for callback in callbacks[type]:
		callback.call()


func trigger_with_payload(type: SignalType, payload: Variant):
	for callback in callbacks[type]:
		callback.call(payload)


func trigger_with_multiload(type: SignalType, payloadOne: Variant, payloadTwo: Variant):
	for callback in callbacks[type]:
		callback.call(payloadOne, payloadTwo)


func trigger_with_node(type: SignalType, payload: Node):
	for callback in callbacks[type]:
		callback.call(payload)


func trigger_with_widget(type: SignalType, payload: Widget):
	for callback in callbacks[type]:
		callback.call(payload)
