class_name HandTrackingUtil

extends Object

enum TrackingType {
	UNKNOWN,
	HAND,
	CONTROLLER
}


####################################################################################################
# Determines whether hand tracking is used or not.
####################################################################################################
static func get_tracking_type_for_hand(is_left: bool) -> TrackingType:
	var tracker_path := "/user/hand_tracker/left" if is_left else "/user/hand_tracker/right"
	var hand_tracker: XRHandTracker = XRServer.get_tracker(tracker_path)

	if hand_tracker == null:
		return TrackingType.UNKNOWN

	if not hand_tracker.has_tracking_data:
		return TrackingType.UNKNOWN

	match hand_tracker.hand_tracking_source:
		XRHandTracker.HAND_TRACKING_SOURCE_UNOBSTRUCTED:
			return TrackingType.HAND
		XRHandTracker.HAND_TRACKING_SOURCE_CONTROLLER:
			return TrackingType.CONTROLLER
		_:
			return TrackingType.UNKNOWN
