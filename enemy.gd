extends RigidBody2D


@export var max_speed: float = 1000.0
@export var gravity_force: float = 50.0

var _targets := []

@onready var _gravity: Area2D = %Gravity


func _ready() -> void:
	apply_torque_impulse(1000)
	_gravity.body_entered.connect(_on_gravity_entered)
	_gravity.body_exited.connect(_on_gravity_exited)


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
	
	var allowable_speed: float = min(max_speed, abs(angular_velocity) * 1000)
	linear_velocity = linear_velocity.limit_length(allowable_speed)
	if angular_velocity <= 0.5:
		linear_velocity = Vector2.ZERO
		set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		set_deferred("freeze", true)


func _on_gravity_entered(body: Node) -> void:
	if body.is_in_group(&"Beyblade") and not body in _targets:
		_targets.append(body)


func _on_gravity_exited(body: Node) -> void:
	if body in _targets:
		_targets.erase(body)
