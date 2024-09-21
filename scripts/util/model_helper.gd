class_name ModelHelper

extends Object


static func scale_model(model: Node, targetSize: float, zoomFactor: float):
	var size = _get_size(model)
		
	var scaleX = true
	var scaleY = false
	var scaleZ = false
	
	var originalSize = size.x
	if size.y > originalSize:
		originalSize = size.y
		scaleX = false
		scaleY = true
	if size.z > originalSize:
		originalSize = size.z
		scaleX = false
		scaleY = false
		scaleZ = true
		
	var scaleFactor = _calculate_scale_factor(targetSize, originalSize, zoomFactor)

	model.scale *= scaleFactor



static func _calculate_scale_factor(targetSizeInM, currentSizeInM, zoomFactor) -> float:
	return (targetSizeInM) / currentSizeInM
	


static func _get_size(model: Node3D) -> Vector3:
	var size = null
	for n in model.get_children().size():
		if "MeshInstance3D"	== model.get_child(n).get_class():
			var mesh:MeshInstance3D = model.get_child(n)
			var aabb : AABB = mesh.get_aabb()
			size = aabb.abs().size
			break;
	return size
