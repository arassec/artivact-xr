class_name ModelHelper

extends Object


static func disable_light(model: Node3D) -> void:
	for n in model.get_children().size():
		if "MeshInstance3D"	== model.get_child(n).get_class():
			var mesh:MeshInstance3D = model.get_child(n)
			var mat:Material = mesh.get_active_material(0)
			if mat:
				mat.shading_mode = 0
				print("SUCCESS")


static func scale_model(model: Node3D, targetSize: float) -> void:
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
		
	var scaleFactor = _calculate_scale_factor(targetSize, originalSize)

	model.scale *= scaleFactor
	

static func _calculate_scale_factor(targetSizeInM, currentSizeInM) -> float:
	var factor = (targetSizeInM) / currentSizeInM
	return factor


static func _get_size(model: Node3D) -> Vector3:
	var size = null
	for n in model.get_children().size():
		if "MeshInstance3D"	== model.get_child(n).get_class():
			var mesh:MeshInstance3D = model.get_child(n)
			var aabb : AABB = mesh.get_aabb()
			size = aabb.abs().size
			break;
	return size
