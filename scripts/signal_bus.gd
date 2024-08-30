extends Node

enum SignalType {
	EXIT_APPLICATION,
	UPDATE_COLLECTION_INFOS, 
	OPEN_SETTINGS,
	NEXT_COLLECTION_INFO,
	PREVIOUS_COLLECTION_INFO,
	UPDATE_SELECTED_COLLECTION,
	OPEN_COLLECTION,
	DELETE_COLLECTION,
	QUIT_COLLECTION
}

var callbacks = {
	SignalType.EXIT_APPLICATION: [],
	SignalType.UPDATE_COLLECTION_INFOS: [],
	SignalType.OPEN_SETTINGS: [],
	SignalType.NEXT_COLLECTION_INFO: [],
	SignalType.PREVIOUS_COLLECTION_INFO: [],
	SignalType.UPDATE_SELECTED_COLLECTION: [],
	SignalType.OPEN_COLLECTION: [],
	SignalType.DELETE_COLLECTION: [],
	SignalType.QUIT_COLLECTION: [],
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
