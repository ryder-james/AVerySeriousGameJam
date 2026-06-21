extends RigidBody2D


const ENEMY_EXPLOSION = preload("uid://b5wh5bhinuutg")

@export var max_speed: float = 1000.0
@export var gravity_force: float = 50.0
@export var initial_spin_force: float = 5.0

var _targets := []

@onready var rpm_agent: RPMAgent = %RPMAgent
@onready var _gravity: Area2D = %Gravity
@onready var _steering: SteeringController = %Steering


func _ready() -> void:
	# I got to this function by just playing around in Desmos until I liked the
	#   multipliers I saw. They are magic numbers in the most literal sense.
	# Takes the form of a((D / b)^2) + 1, where D is how far the player has
	#   traveled, minus the minimum distance to start scaling, to a minimum of 0.
	#   Therefore, scaling will be 1 until min_distance is reached.
	# We add 1 at the end so that our scaling is never 0, it always starts at at
	#   least 1.
	# a and b both affect how steep the curve is, with a having a much stronger
	#   impact and therefore b being a much more granular adjustment. b's impact
	#   is also inversely proportional, so a larger b creates a more gradual curve
	# https://www.desmos.com/calculator/woqwasyj9z
	const a: float = 6.0
	const b: float = 250.0
	const min_distance: float = 100.0
	var distance_stat: float = max(Game.player_distance - min_distance, 0)
	var initial_torque_multiplier = a * ((distance_stat / b) ** 2) + 1
	apply_torque_impulse(initial_spin_force * initial_torque_multiplier)
	_gravity.body_entered.connect(_on_gravity_entered)
	_gravity.body_exited.connect(_on_gravity_exited)


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	apply_central_force(_steering.get_steering_vector(
			gravity_force, _gravity.get_child(0).shape.radius, max_speed))
	
	var allowable_speed: float = min(max_speed, abs(angular_velocity) * 1000)
	linear_velocity = linear_velocity.limit_length(allowable_speed)
	if rpm_agent.rpm < 0.01:
		stop_instant()


func stop_instant() -> void:
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	set_deferred("freeze", true)
	_gravity.body_entered.disconnect(_on_gravity_entered)
	_gravity.body_exited.disconnect(_on_gravity_exited)
	get_tree().create_timer(3.0).timeout.connect(queue_free)


func kill() -> void:
	var explosion := ENEMY_EXPLOSION.instantiate() as CPUParticles2D
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	stop_instant()
	visible = false
	#queue_free()


func _on_gravity_entered(body: Node) -> void:
	if body.is_in_group(&"Beyblade") and not body in _targets:
		_targets.append(body)


func _on_gravity_exited(body: Node) -> void:
	if body in _targets:
		_targets.erase(body)
