class_name ComponentType

extends Object

var dir: String
var file: String

static var PROPERTIES_CONFIG := ComponentType.new("configs", "properties.artivact.config.json")
static var TAGS_CONFIG := ComponentType.new("configs", "tags.artivact.config.json")
static var MENU := ComponentType.new("menus", "artivact.menu.json")
static var ITEM := ComponentType.new("items", "artivact.item.json")
static var PAGE := ComponentType.new("pages", "artivact.page.json")
static var WIDGET := ComponentType.new("widgets", "artivact.search-result.json")

func _init(dirParam: String, fileParam: String):
	dir = dirParam
	file = fileParam
