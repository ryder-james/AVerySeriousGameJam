extends RigidBody2D


signal die
signal start_dash
signal end_dash


@export var max_speed: float = 1000.0
@export var max_launch_power: float = 800.0
@export var dash_strength: float = 500.0
@export var gravity_force: float = 50.0
@export var clash_detection_distance: float = 90.0

var is_dashing := false
var _dash_angle := 0.0

@onready var rpm_agent: RPMAgent = %RPMAgent
@onready var _default_angular_damp: float = angular_damp


func _ready() -> void:
	Game.launch.connect(
			func(power: float, launch_angle: float):
				var speed = power * max_launch_power
				apply_torque_impulse(speed/50)
				apply_central_impulse((Vector2.RIGHT * speed).rotated(launch_angle))
				process_mode = Node.PROCESS_MODE_INHERIT
	)
	Game.clash.connect(_on_clash)
	Game.player = self


func _process(_delta: float) -> void:
	if roundi(global_position.x / 100) > Game.player_distance:
		Game.player_distance = roundi(global_position.x / 100)
		
	if not is_dashing:
		return
	if Input.is_action_pressed("ccw"):
		_dash_angle = deg_to_rad(-45.0)
	elif Input.is_action_pressed("cw"):
		_dash_angle = deg_to_rad(45.0)
	else:
		_dash_angle = 0.0


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	var allowable_speed: float = min(max_speed, abs(angular_velocity) * 1000)
	linear_velocity.x = max(linear_velocity.x, -200)
	linear_velocity = linear_velocity.limit_length(allowable_speed)
	if linear_velocity.length() < 10 or rpm_agent.rpm < 0.01:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		die.emit()
		set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		set_deferred("freeze", true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("launch"):
		start_dash.emit()
		is_dashing = true
		print("start")
	elif is_dashing and event.is_action_released("launch"):
		end_dash.emit()
		apply_central_impulse((Vector2.RIGHT * dash_strength).rotated(_dash_angle))
		print("end")


func _on_clash(_player_rpm: RPMAgent, _enemy_rpm: RPMAgent, result: Game.ClashResult):
	if result == Game.ClashResult.PLAYER_SUPER_VICTORY:
		_on_enemy_killed()
	elif result == Game.ClashResult.PLAYER_VICTORY:
		body_entered.connect(_on_clash_kill)
	else:
		body_entered.connect(_on_clash_die)


func _on_clash_kill(body: Node) -> void:
	if body.is_in_group(&"Enemy"):
		body.angular_damp = 4.0
		body.angular_damp_mode = DAMP_MODE_REPLACE
		_on_enemy_killed()
		body_entered.disconnect(_on_clash_kill)


func _on_clash_die(body: Node) -> void:
	if body.is_in_group(&"Enemy"):
		angular_damp = 4.0
		body_entered.disconnect(_on_clash_die)


func _on_enemy_killed() -> void:
	angular_damp = 0.0
	angular_velocity *= 3
	linear_velocity *= 3
	get_tree().create_timer(3.0).timeout.connect(func(): angular_damp = _default_angular_damp)
