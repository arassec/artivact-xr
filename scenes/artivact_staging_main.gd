extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var progressBar = get_parent().find_child("ProgressBar")
	if progressBar != null:
		progressBar.visible = false
