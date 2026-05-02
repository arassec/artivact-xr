extends Node3D


const NO_INTERSECTION := Vector2(-1.0, -1.0)

## Maximum distance (in metres) at which hover (MouseMotion) events are sent.
@export var hover_distance: float = 0.08

## Distance (in metres) at which a click (MouseButton) event is triggered.
@export var click_distance: float = 0.02

## Minimum time in seconds between two simulated clicks.
@export var click_cooldown: float = 0.75

## The SubViewport that receives the synthesised mouse events.
@export var viewport: SubViewport

## The composition layer whose surface is used for hit-testing.
@export var composition_layer: OpenXRCompositionLayerQuad

## The player to play the 'click' sound when clicking.
@export var audio_player: AudioStreamPlayer


var _was_clicking: bool = false
var _last_intersect: Vector2 = NO_INTERSECTION
var _click_cooldown_remaining: float = 0.0


func _process(delta: float) -> void:
	if _click_cooldown_remaining > 0.0:
		_click_cooldown_remaining = max(0.0, _click_cooldown_remaining - delta)

	if not viewport or not composition_layer:
		return

	var finger_pos: Vector3 = global_position
	var layer_normal: Vector3 = composition_layer.global_transform.basis.z

	var signed_dist: float = layer_normal.dot(
		finger_pos - composition_layer.global_position
	)

	if signed_dist <= 0.0 or signed_dist > hover_distance:
		_clear_state()
		return

	var intersect: Vector2 = composition_layer.intersects_ray(finger_pos, -layer_normal)

	if intersect == NO_INTERSECTION:
		_clear_state()
		return

	var viewport_pos: Vector2i = _intersect_to_viewport_pos(intersect)

	if signed_dist <= click_distance:
		if not _was_clicking and _click_cooldown_remaining <= 0.0:
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
			
			if audio_player:
				audio_player.play()

			_click_cooldown_remaining = click_cooldown

		_was_clicking = true
	else:
		_was_clicking = false

		if _last_intersect == NO_INTERSECTION:
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


func _intersect_to_viewport_pos(intersect: Vector2) -> Vector2i:
	if viewport and intersect != NO_INTERSECTION:
		return Vector2i(intersect * Vector2(viewport.size))
	return Vector2i(-1, -1)
