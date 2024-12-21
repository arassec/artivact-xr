class_name ArtivactTagsConfigurationJson

extends Object


var tags: Array[Tag] = []


func _init(data: Dictionary):
	if data:
		if data.has("tags"):
			for tag in data["tags"]:
				tags.append(Tag.new(tag))
