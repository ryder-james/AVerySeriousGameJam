class_name RPMAgent
extends Node2D


@export var parent_rb: RigidBody2D = null


var rpm: float:
	get = get_rpm


func get_rpm() -> float:
	if not parent_rb:
		return 0.0
	
	return floorf(parent_rb.angular_velocity / TAU * 100) * 0.01
