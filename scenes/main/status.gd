extends Node


func _init():
	SignalBus.register(SignalBus.SignalType.COLLECTION_INFOS_UPDATED, _collection_infos_updated)
	SignalBus.register(SignalBus.SignalType.DOWNLOAD_COLLECTION_FINISHED, _download_collection_finished)


func _enter_tree():
	$StatusLabel.text = ''
	

func _exit_tree():
	SignalBus.deregister(SignalBus.SignalType.COLLECTION_INFOS_UPDATED, _collection_infos_updated)
	SignalBus.deregister(SignalBus.SignalType.DOWNLOAD_COLLECTION_FINISHED, _download_collection_finished)
	

func _collection_infos_updated(success: bool):
	if !success:
		$StatusLabel.text = 'Synchronizing... failed!'


func _download_collection_finished(success: bool):
	if !success:
		$StatusLabel.text = 'Downloading... failed!'
