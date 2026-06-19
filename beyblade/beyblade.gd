extends RigidBody2D


@export var max_speed: float = 3000.0
@export var rotation_speed: float = 1500.0

var speed: float = 0.0

@onready var _visual: Sprite2D = %Visual


func _ready() -> void:
	Game.launch.connect(
			func(power: float, launch_angle: float):
				speed = power * max_speed
				apply_central_impulse((Vector2.RIGHT * speed).rotated(launch_angle))
	)


func _process(delta: float) -> void:
	var scaled_speed: float = linear_velocity.length() / max_speed
	var vis_rotation: float = -scaled_speed * PI * 2 * rotation_speed * delta
	_visual.rotation = wrapf(vis_rotation, -PI, PI)
