class_name PaginationContainer

extends Control


@export var pageSize: int = 1
@export var columns: int = 1

var curPage: int = 0
var totalPages: int = 0

var totalContent: Array[Object] = []
var pageContent: Array[Object] = []


func set_content(totalContentInput: Array[Object]) -> void:
	$ContentMargin/ContentContainer/ContentAnchor.columns = columns

	totalContent = totalContentInput
	@warning_ignore("integer_division")
	totalPages = totalContent.size() / pageSize
	if totalContent.size() % pageSize > 0:
		totalPages += 1
	_update_page(0)


func set_left_actions(leftActionsInput: Array[Object]) -> void:
	for actionChild in leftActionsInput:
		$ContentMargin/ContentContainer/ActionBarContainer/LeftActionsAnchor.add_child(actionChild)


func set_right_actions(rightActionsInput: Array[Object]) -> void:
	for actionChild in rightActionsInput:
		$ContentMargin/ContentContainer/ActionBarContainer/RightActionsAnchor.add_child(actionChild)


func _update_page(page: int) -> void:
	curPage = page
	_clear_page()
	for contentChild in _get_page_content(page):
		$ContentMargin/ContentContainer/ContentAnchor.add_child(contentChild)
	_update_page_label()

	
func _clear_page() -> void:
	for contentChild in $ContentMargin/ContentContainer/ContentAnchor.get_children():
		$ContentMargin/ContentContainer/ContentAnchor.remove_child(contentChild)


func _get_page_content(page: int) -> Array[Object]:
	var result: Array[Object] = []
	
	var startIndex = page * pageSize
	var endIndex = min(startIndex + pageSize, totalContent.size())

	for index in endIndex - startIndex:
		result.push_back(totalContent[startIndex + index])
	
	return result


func _update_page_label() -> void: 
	$ContentMargin/ContentContainer/ActionBarContainer/Pager/PageLabel.text = str(curPage + 1, " / ", totalPages)


func _on_before_button_pressed() -> void:
	if curPage > 0:
		_update_page(curPage -1)


func _on_next_button_pressed() -> void:
	if curPage + 1 < totalPages:
		_update_page(curPage + 1)
