extends Node3D

## RcFingerPointer
##
## Attached to the right index-finger tip (via BoneAttachment3D).
## Translates finger proximity to an OpenXRCompositionLayerQuad into 2D mouse
## events that are forwarded to the SubViewport rendered inside that layer.
##
## * When the finger is within [hover_distance] metres of the quad surface a
##   MouseMotion event is pushed so UI elements highlight on hover.
## * When the finger is within [click_distance] metres (or touching) the quad a
##   left-mouse-button press+release pair is pushed – once per approach.

const NO_INTERSECTION := Vector2(-1.0, -1.0)

## Maximum distance (in metres) at which hover (MouseMotion) events are sent.
@export var hover_distance: float = 0.08

## Distance (in metres) at which a click (MouseButton) event is triggered.
@export var click_distance: float = 0.02

## The SubViewport that receives the synthesised mouse events.
@export var viewport: SubViewport

## The composition layer whose surface is used for hit-testing.
@export var composition_layer: OpenXRCompositionLayerQuad

var _was_clicking: bool = false
var _last_intersect: Vector2 = NO_INTERSECTION


func _process(_delta: float) -> void:
	if not viewport or not composition_layer:
		return

	# The BoneAttachment3D positions this node at the right index-finger tip.
	var finger_pos: Vector3 = global_position

	# The quad's local Z axis points outward (toward the viewer / the finger).
	var layer_normal: Vector3 = composition_layer.global_transform.basis.z

	# Signed distance: positive means the finger is in front of the layer.
	var signed_dist: float = layer_normal.dot(
		finger_pos - composition_layer.global_position
	)

	# Only process when the finger is in front of the layer and within hover range.
	if signed_dist <= 0.0 or signed_dist > hover_distance:
		_clear_state()
		return

	# Cast a ray from the finger tip straight toward the layer surface.
	var intersect: Vector2 = composition_layer.intersects_ray(finger_pos, -layer_normal)

	if intersect == NO_INTERSECTION:
		_clear_state()
		return

	var viewport_pos: Vector2i = _intersect_to_viewport_pos(intersect)

	if signed_dist <= click_distance:
		# Finger is touching / very close to the layer – fire a click once per approach.
		if not _was_clicking:
			var press_event := InputEventMouseButton.new()
			press_event.button_index = MOUSE_BUTTON_LEFT
			press_event.button_mask = MOUSE_BUTTON_MASK_LEFT
			press_event.pressed = true
			press_event.position = viewport_pos
			viewport.push_input(press_event)

			var release_event := InputEventMouseButton.new()
			release_event.button_index = MOUSE_BUTTON_LEFT
			release_event.button_mask = 0
			release_event.pressed = false
			release_event.position = viewport_pos
			viewport.push_input(release_event)

		_was_clicking = true
	else:
		_was_clicking = false

		# Finger is hovering – send mouse motion so UI elements get hover highlights.
		if _last_intersect == NO_INTERSECTION:
			# First frame of hover – send an initial position event.
			var motion_event := InputEventMouseMotion.new()
			motion_event.position = viewport_pos
			viewport.push_input(motion_event)
		elif intersect != _last_intersect:
			var motion_event := InputEventMouseMotion.new()
			var from: Vector2i = _intersect_to_viewport_pos(_last_intersect)
			motion_event.relative = Vector2(viewport_pos) - Vector2(from)
			motion_event.position = viewport_pos
			viewport.push_input(motion_event)

	_last_intersect = intersect


func _clear_state() -> void:
	_was_clicking = false
	_last_intersect = NO_INTERSECTION


# Convert a normalised UV intersection point to integer viewport coordinates.
func _intersect_to_viewport_pos(intersect: Vector2) -> Vector2i:
	if viewport and intersect != NO_INTERSECTION:
		return Vector2i(intersect * Vector2(viewport.size))
	return Vector2i(-1, -1)
