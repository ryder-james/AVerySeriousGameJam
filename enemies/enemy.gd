extends RigidBody2D


@export var max_speed: float = 1000.0
@export var gravity_force: float = 50.0

var _targets := []

@onready var _gravity: Area2D = %Gravity
@onready var _steering: SteeringController = %Steering


func _ready() -> void:
	apply_torque_impulse(1000)
	_gravity.body_entered.connect(_on_gravity_entered)
	_gravity.body_exited.connect(_on_gravity_exited)


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	apply_central_force(_steering.get_steering_vector(
			gravity_force, _gravity.get_child(0).shape.radius, max_speed))
	
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
