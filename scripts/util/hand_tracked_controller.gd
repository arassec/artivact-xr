extends XRController3D


var was_pickup_pressed : bool = false


@export var tablet: Tablet


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Check if we can use our palm pose or should fallback to our grip pose.
	var controller_tracker : XRControllerTracker = XRServer.get_tracker(tracker)
	if controller_tracker:
		var new_pose : String = "palm_pose"
		var xr_pose : XRPose = controller_tracker.get_pose(new_pose)
		if not xr_pose or xr_pose.tracking_confidence == XRPose.XR_TRACKING_CONFIDENCE_NONE:
			new_pose = "grip"

		if pose != new_pose:
			pose = new_pose

	# Detect grip with hand tracking enabled:
	var pickup_pressed = false

	var pickup_value : float = get_float("grip")
	var threshold : float = 0.9 if was_pickup_pressed else 0.99
	pickup_pressed = pickup_value > threshold
	
	if SettingsStore.is_tablet_picked_up():
		return
	
	if was_pickup_pressed and not pickup_pressed:
		SignalBus.trigger_with_payload(SignalBus.SignalType.CTRL_GRIP_RELEASED, self)

	if tablet:
		# Pickup only if far enough away from tablet!
		var distanceToTablet = global_position.distance_to(tablet.get_global_pos())
		if distanceToTablet < 0.4:
			return
				
		if not was_pickup_pressed and pickup_pressed:
			SignalBus.trigger_with_payload(SignalBus.SignalType.CTRL_GRIP_PRESSED, self)
			
	was_pickup_pressed = pickup_pressed
