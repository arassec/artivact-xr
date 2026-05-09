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

	### Detect hand-tracked gripping ###########################

	# First check, if the palm is looking upwards, to avoid accidental grips:
	var basis := global_transform.basis
	var palm_normal := -basis.z.normalized()
	var value := palm_normal.dot(Vector3.RIGHT)
	if !was_pickup_pressed && tracker == "left_hand" \
			&& HandTrackingUtil.get_tracking_type_for_hand(true) == HandTrackingUtil.TrackingType.HAND \
			&& value > -0.65:
		return
	if !was_pickup_pressed && tracker == "right_hand"  \
			&& HandTrackingUtil.get_tracking_type_for_hand(false) == HandTrackingUtil.TrackingType.HAND \
			&& value < 0.65:
		return
	
	# If the tablet is picked up, we don't want any other object to be grabbed:
	if SettingsStore.is_tablet_picked_up():
		return
		
	# Detect grip with hand tracking enabled:
	var pickup_pressed = false
	var pickup_value : float = get_float("grip")
	var threshold : float = 0.9 if was_pickup_pressed else 0.99
	pickup_pressed = pickup_value > threshold
	
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
