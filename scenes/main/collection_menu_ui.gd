extends Node


func open_collection():
	SignalBus.trigger(SignalBus.SignalType.OPEN_COLLECTION)


func delete_collection():
	SignalBus.trigger(SignalBus.SignalType.OPEN_COLLECTION)
