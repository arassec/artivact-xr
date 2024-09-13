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
	QUIT_COLLECTION,
	UPDATE_PAGE_NAVIGATION,
	OPEN_PAGE,
	UPDATE_WIDGET_NAVIGATION,
	OPEN_WIDGET
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
	SignalType.QUIT_COLLECTION: [],
	SignalType.UPDATE_PAGE_NAVIGATION: [],
	SignalType.OPEN_PAGE: [],
	SignalType.UPDATE_WIDGET_NAVIGATION: [],
	SignalType.OPEN_WIDGET: [],
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
