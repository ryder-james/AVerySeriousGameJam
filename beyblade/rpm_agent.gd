class_name RPMAgent
extends Node2D


@export var parent_rb: RigidBody2D = null


var rpm: float:
	get = get_rpm


func get_rpm() -> float:
	if not parent_rb or not is_instance_valid(parent_rb):
		return 0.0
	
	var rps := parent_rb.angular_velocity / TAU
	if is_equal_approx(rps, 300):
		return 300
	return floorf(rps * 100) * 0.01
