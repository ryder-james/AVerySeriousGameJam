extends RigidBody2D


@export var max_speed: float = 1000.0


func _ready() -> void:
	apply_torque_impulse(1000)


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	var allowable_speed: float = min(max_speed, abs(angular_velocity) * 1000)
	linear_velocity = linear_velocity.limit_length(allowable_speed)
