extends Node


func quit_collection():
	SignalBus.trigger(SignalBus.SignalType.QUIT_COLLECTION)
