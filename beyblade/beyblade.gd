extends RigidBody2D


@export var max_speed: float = 1000.0
@export var max_launch_power: float = 500.0

var speed: float = 0.0


func _ready() -> void:
	Game.launch.connect(
			func(power: float, launch_angle: float):
				speed = power * max_launch_power
				apply_torque_impulse(speed)
				apply_central_impulse((Vector2.RIGHT * speed).rotated(launch_angle))
				process_mode = Node.PROCESS_MODE_INHERIT
	)


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	print(angular_velocity)
	var allowable_speed: float = min(max_speed, abs(angular_velocity) * 10)
	linear_velocity = linear_velocity.limit_length(allowable_speed)
	if linear_velocity.length() < 10:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
