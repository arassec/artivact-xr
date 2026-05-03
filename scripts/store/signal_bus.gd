extends Node


var debugLogSignals = false


enum SignalType {
	DEBUG,
	
	CTRL_GRIP_PRESSED,
	CTRL_GRIP_RELEASED,
	CTRL_TRIGGER_PRESSED,
	CTRL_TRIGGER_RELEASED,
	
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
	COLL_CLOSE_WIDGET
}

var callbacks = {
	SignalType.DEBUG: [],

	SignalType.CTRL_GRIP_PRESSED: [],
	SignalType.CTRL_GRIP_RELEASED: [],
	SignalType.CTRL_TRIGGER_PRESSED: [],
	SignalType.CTRL_TRIGGER_RELEASED: [],

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
	SignalType.COLL_CLOSE_WIDGET: [],
}


func register(type: SignalType, callback: Callable):
	callbacks[type].push_back(callback)


func deregister(type: SignalType, callback: Callable):
	callbacks[type].erase(callback)


func trigger(type: SignalType):
	if debugLogSignals:
		debug_json({"type": type})
	for callback in callbacks[type]:
		if !callback.is_null():
			callback.call()
		else:
			deregister(type, callback)


func trigger_with_payload(type: SignalType, payload: Variant):
	if debugLogSignals:
		debug_json({"type": type, "payload": payload})
	for callback in callbacks[type]:
		if !callback.is_null():
			callback.call(payload)
		else:
			deregister(type, callback)


func trigger_with_multiload(type: SignalType, payloadOne: Variant, payloadTwo: Variant):
	if debugLogSignals:
		debug_json({"type": type, "payloadOne": payloadOne, "payloadTwo": payloadTwo})
	for callback in callbacks[type]:
		if callback:
			callback.call(payloadOne, payloadTwo)


func trigger_with_node(type: SignalType, payload: Node):
	if debugLogSignals:
		debug_json({"type": type, "payload": payload})
	for callback in callbacks[type]:
		if callback:
			callback.call(payload)


func trigger_with_widget(type: SignalType, payload: Widget):
	if debugLogSignals:
		debug_json({"type": type, "payload": payload})
	for callback in callbacks[type]:
		if callback:
			callback.call(payload)


func debug(payload: String) -> void:
	for callback in callbacks[SignalType.DEBUG]:
		callback.call_deferred(payload)


func debug_json(payload: Dictionary):
	for callback in callbacks[SignalType.DEBUG]:
		callback.call_deferred(payload)
