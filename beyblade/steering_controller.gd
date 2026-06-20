class_name SteeringController
extends Node2D


@export var attraction_strength_curve: Curve = null

var targets: Array[Node2D]


func get_steering_vector(steering_strength: float, max_distance: float, max_speed: float) -> Vector2:
	if not targets.is_empty():
		var avg_target_point := Vector2.ZERO
		for target: Node2D in targets:
			if target.global_position.x < global_position.x:
				continue
			var distance: float = (global_position.distance_to(target.global_position))
			var strength: float = 1 - (distance / max_distance)
			avg_target_point += target.global_position * attraction_strength_curve.sample(strength)
		avg_target_point /= targets.size()
		var steering_dir := avg_target_point - global_position
		return steering_dir * (steering_strength / max_speed)
	return Vector2.ZERO
