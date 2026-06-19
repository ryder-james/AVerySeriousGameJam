extends RigidBody2D


@export var max_speed: float = 1000.0

var speed: float = 0.0

@onready var visual: Sprite2D = %Visual


func _ready() -> void:
	Game.launch.connect(
			func(power: float, launch_angle: float):
				speed = power * max_speed
				apply_central_impulse((Vector2.RIGHT * speed).rotated(launch_angle))
	)
