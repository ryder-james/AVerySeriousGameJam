class_name Beyblade
extends RigidBody2D


signal die
signal dash_start
signal dash_end
signal dash_recharge


const DASH_RIGHT := deg_to_rad(0.0)
const DASH_DOWN := deg_to_rad(45.0)
const DASH_UP := -DASH_DOWN

@export var max_speed: float = 1000.0
@export var max_launch_power: float = 800.0
@export var dash_strength: float = 500.0
@export var max_dash_duration: float = 1.0
@export var gravity_force: float = 50.0
@export var clash_detection_distance: float = 90.0

var max_dash_charges: int = 1
var is_dashing := false
var dash_duration := 0.0
var _preferred_dash_angle := DASH_RIGHT
var _dash_tween: Tween = null

@onready var rpm_agent: RPMAgent = %RPMAgent
@onready var dash_charges: int = max_dash_charges
@onready var _default_angular_damp: float = angular_damp
@onready var _dash_recharge_timer: Timer = %DashRechargeTimer


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
	_dash_recharge_timer.timeout.connect(_on_dash_recharge)


func _process(_delta: float) -> void:
	if roundi(global_position.x / 100) > Game.player_distance:
		Game.player_distance = roundi(global_position.x / 100)


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
	if is_dashing:
		var release_dash := false
		var dash_angle := DASH_RIGHT
		if event.is_action_released("launch"):
			release_dash = true
			dash_angle = _preferred_dash_angle
		elif event.is_action_pressed("ccw"):
			dash_angle = DASH_UP
			release_dash = true
		elif event.is_action_pressed("cw"):
			dash_angle = DASH_DOWN
			release_dash = true
		if release_dash:
			_release_dash(dash_angle)
	else:
		if dash_charges > 0 and event.is_action_pressed("launch"):
			dash_charges -= 1
			dash_start.emit()
			is_dashing = true
			dash_duration = max_dash_duration
			_dash_tween = create_tween()
			_dash_tween.set_ignore_time_scale(true)
			_dash_tween.tween_property(self, "dash_duration", 0.0, max_dash_duration)
			_dash_tween.finished.connect(_release_dash.bind(_preferred_dash_angle))
		elif event.is_action_pressed("ccw"):
			_preferred_dash_angle = DASH_UP
		elif event.is_action_pressed("cw"):
			_preferred_dash_angle = DASH_DOWN
		elif event.is_action_released("ccw") or event.is_action_released("cw"):
			_preferred_dash_angle = DASH_RIGHT


func _release_dash(angle: float) -> void:
	if _dash_tween:
		_dash_tween.stop()
	_preferred_dash_angle = 0.0
	is_dashing = false
	apply_central_impulse((Vector2.RIGHT * dash_strength).rotated(angle))
	dash_end.emit()


func _on_dash_recharge() -> void:
	dash_charges = min(dash_charges + 1, max_dash_charges)
	dash_recharge.emit()


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
