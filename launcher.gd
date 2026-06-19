extends Node2D


signal launch(power: float, angle: float)


@export_category("Launch Slider")
@export var max_offset: float = 1.0
@export var speed: float = 2.0

@export_category("Launcher Angle")
@export_range(-45, 45, 0.1, "radians_as_degrees") var max_angle: float = deg_to_rad(30.0)
@export_range(0.1, 90.0, 0.1, "radians_as_degrees") var rotation_speed: float = deg_to_rad(60.0)

var _stopped: bool = false

@onready var _launcher_selector: Node2D = %LauncherSelector
@onready var _barrel: Node2D = %Barrel


func _process(delta: float) -> void:
	if not _stopped:
		_launcher_selector.position.y = _get_sin() * max_offset
	if Input.is_action_just_pressed("launch"):
		if !_stopped:
			_stopped = true
			launch.emit(_get_power(), _barrel.rotation)
		else:
			print("reload")
			get_tree().reload_current_scene()
	if not _stopped and Input.is_action_pressed("ccw"):
		_barrel.rotation -= rotation_speed * delta
	elif not _stopped and Input.is_action_pressed("cw"):
		_barrel.rotation += rotation_speed * delta
	
	_barrel.rotation = clamp(_barrel.rotation, -max_angle, max_angle)


func _get_sin() -> float:
	return sin(Time.get_ticks_msec() * 0.001 * speed)


func _get_power() -> float:
	return ((1 - abs(_get_sin())) + 1) * 0.5
