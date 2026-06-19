extends RigidBody2D


const Launcher = preload("uid://b88xopbqawg6t")


@export var max_speed: float = 1000.0

var speed: float = 0.0

@onready var visual: Sprite2D = %Visual
@onready var launcher: Launcher = $"../Launcher"


func _ready() -> void:
	launcher.launch.connect(
			func(power: float, launch_angle: float):
				speed = power * max_speed
				apply_central_impulse((Vector2.RIGHT * speed).rotated(launch_angle))
	)
