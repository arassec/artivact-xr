class_name ContentExports

extends Object

var contentExports: Array[ContentExport] = []


func _init(data: Array[Dictionary]):
	if data:
		for contentExport in data:
			contentExports.append(ContentExport.new(contentExport))
