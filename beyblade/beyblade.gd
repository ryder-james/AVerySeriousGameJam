extends RigidBody2D


@export var max_speed: float = 1000.0
@export var max_launch_power: float = 500.0
@export var gravity_force: float = 50.0

var _targets := []

@onready var _gravity: Area2D = %Gravity
@onready var _clash_zone: Area2D = %ClashZone


func _ready() -> void:
	Game.launch.connect(
			func(power: float, launch_angle: float):
				var speed = power * max_launch_power
				apply_torque_impulse(speed)
				apply_central_impulse((Vector2.RIGHT * speed).rotated(launch_angle))
				process_mode = Node.PROCESS_MODE_INHERIT
	)
	_gravity.body_entered.connect(_on_gravity_entered)
	_gravity.body_exited.connect(_on_gravity_exited)
	_clash_zone.body_entered.connect(_on_clash_zone_body_entered)


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	if not _targets.is_empty():
		var avg_target_point := Vector2.ZERO
		for target: Node2D in _targets:
			var distance: float = (global_position.distance_to(target.global_position))
			var strength: float = 1 - (distance / _gravity.get_child(0).shape.radius)
			avg_target_point += target.global_position * strength
		avg_target_point /= _targets.size()
		var steering_dir := avg_target_point - global_position
		apply_central_force(steering_dir * (gravity_force / max_speed))
	
	
	var allowable_speed: float = min(max_speed, abs(angular_velocity) * 10)
	linear_velocity = linear_velocity.limit_length(allowable_speed)
	if linear_velocity.length() < 10:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		set_deferred("freeze", true)


func _on_gravity_entered(body: Node) -> void:
	if body.is_in_group(&"Beyblade") and not body in _targets:
		_targets.append(body)


func _on_gravity_exited(body: Node) -> void:
	if body in _targets:
		_targets.erase(body)


func _on_clash_zone_body_entered(body: Node) -> void:
	if body.is_in_group(&"Enemy"):
		_clash(body as PhysicsBody2D)


func _clash(enemy: PhysicsBody2D) -> void:
	enemy.angular_damp = 4.0
	enemy.angular_damp_mode = DAMP_MODE_REPLACE
	angular_damp = 0.0
	get_tree().create_timer(3.0).timeout.connect(func(): angular_damp = 1.0)
	Game.clash()
