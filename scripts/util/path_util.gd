class_name PathUtil

extends Object

####################################################################################################
# TODO
####################################################################################################
static func get_default_file_path(type: ComponentType, id: String) -> String:
	var result = str(type.dir, "/", id.substr(0, 3), "/", id.substr(3, 3), "/", id, "/", type.file)
	print("File path: %s" % result)
	return result


####################################################################################################
# TODO
####################################################################################################
static func get_file_path(type: ComponentType, id: String, file: String) -> String:
	var result = str(type.dir, "/", id.substr(0, 3), "/", id.substr(3, 3), "/", id, "/", file)
	print("File path: %s" % result)
	return result


####################################################################################################
# TODO
####################################################################################################
static func get_subdir_file_path(type: ComponentType, id: String, subdir: String, file: String) -> String:
	var result = str(type.dir, "/", id.substr(0, 3), "/", id.substr(3, 3), "/", id, "/", subdir, "/", file)
	print("Subdir file path: %s" % result)
	return result
