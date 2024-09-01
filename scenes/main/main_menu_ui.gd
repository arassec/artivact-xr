extends Node


func exit_application():
	SignalBus.trigger(SignalBus.SignalType.EXIT_APPLICATION)


func update_collection_infos():
	SignalBus.trigger(SignalBus.SignalType.UPDATE_REMOTE_COLLECTION_INFOS)


func open_settings():
	SignalBus.trigger(SignalBus.SignalType.OPEN_SETTINGS)
