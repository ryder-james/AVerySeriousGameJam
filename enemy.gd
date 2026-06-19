extends StaticBody2D


var rotation_speed: float = 0.0

@onready var visual: Sprite2D = %Visual


func _ready() -> void:
	rotation_speed = randf_range(PI, TAU)
	constant_angular_velocity = deg_to_rad(rotation_speed)


func _process(delta: float) -> void:
	visual.rotation = wrapf(visual.rotation + (rotation_speed * delta), 0, TAU)
