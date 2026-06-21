extends RigidBody2D


signal death


@export var max_speed: float = 1000.0
@export var max_launch_power: float = 800.0
@export var gravity_force: float = 50.0
@export var clash_detection_distance: float = 90.0

var _targets: Array[Node2D] = []

@onready var rpm_agent: RPMAgent = %RPMAgent
@onready var _gravity: Area2D = %Gravity
@onready var _steering: SteeringController = %Steering


func _ready() -> void:
	Game.launch.connect(
			func(power: float, launch_angle: float):
				var speed = power * max_launch_power
				apply_torque_impulse(speed/50)
				apply_central_impulse((Vector2.RIGHT * speed).rotated(launch_angle))
				process_mode = Node.PROCESS_MODE_INHERIT
	)
	Game.player = self
	_gravity.body_entered.connect(_on_gravity_entered)
	_gravity.body_exited.connect(_on_gravity_exited)
	body_entered.connect(_on_hit)


func _process(_delta: float) -> void:
	if roundi(global_position.x / 100) > Game.player_distance:
		Game.player_distance = roundi(global_position.x / 100)


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	_steering.targets = _targets
	apply_central_force(_steering.get_steering_vector(
			gravity_force, _gravity.get_child(0).shape.radius, max_speed))
	
	var allowable_speed: float = min(max_speed, abs(angular_velocity) * 1000)
	linear_velocity.x = max(linear_velocity.x, -200)
	linear_velocity = linear_velocity.limit_length(allowable_speed)
	if linear_velocity.length() < 10:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		death.emit()
		set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		set_deferred("freeze", true)


func _on_gravity_entered(body: Node) -> void:
	if body.is_in_group(&"Beyblade") and not body in _targets:
		_targets.append(body)


func _on_gravity_exited(body: Node) -> void:
	if body in _targets:
		_targets.erase(body)


func _on_hit(body:Node) -> void:
	if body.is_in_group(&"Enemy"):
		_strike_enemy(body as PhysicsBody2D)


func _strike_enemy(enemy: Node) -> void:
	enemy.angular_damp = 4.0
	enemy.angular_damp_mode = DAMP_MODE_REPLACE
	angular_damp = 0.0
	angular_velocity *= 1.3
	linear_velocity *= 1.3
	get_tree().create_timer(3.0).timeout.connect(func(): angular_damp = 1.0)
