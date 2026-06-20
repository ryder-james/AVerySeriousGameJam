extends Node2D


@export var spawn_points: Array[Marker2D] = []
## The chance that a single point in [code]spawn_points[/code] will spawn an 
## enemy. An enemy is guaranteed to spawn for each multiple of 1, with percentages
## beyond multiples of 1 providing a chance for an additional enemy. Enemies will
## spawn spread out between all spawn points, and this wave will never spawn more
## enemies than there are points.
@export_range(0.01, 1.0, 0.01, "or_greater") var spawn_chance: float = 1.0
@export var _enemy_scenes: Array[PackedScene] = []

@onready var _spawn_trigger_wall: Area2D = %SpawnTriggerWall


func _ready() -> void:
	_spawn_trigger_wall.body_entered.connect(_spawn_wall_hit)


func _spawn_wall_hit(body: Node) -> void:
	if not body.is_in_group(&"Player"):
		return
	
	var guaranteed_spawn_count: int = floori(spawn_chance)
	var marginal_spawn_chance: float = spawn_chance - guaranteed_spawn_count
	var available_spawn_points: Array[Marker2D] = []
	available_spawn_points.append_array(spawn_points)
	for i in min(guaranteed_spawn_count, spawn_points.size()):
		var spawn_point: Marker2D = available_spawn_points.pick_random()
		available_spawn_points.erase(spawn_point)
		_spawn_enemy(spawn_point)
	if (not available_spawn_points.is_empty()) and randf() <= marginal_spawn_chance:
		_spawn_enemy(available_spawn_points.pick_random())
	
	queue_free()


func _spawn_enemy(spawn_point: Marker2D) -> void:
	var scene: PackedScene = _enemy_scenes.pick_random()
	var enemy: Node2D = scene.instantiate()
	call_deferred("add_sibling", enemy)
	enemy.set_deferred("global_position", spawn_point.global_position)
	var max_angle: float = deg_to_rad(60)
	var rand_angle: float = randf_range(-max_angle, max_angle)
	enemy.call_deferred("apply_central_impulse", Vector2.UP * rand_angle * 100)
