extends Node2D


@export var distance_from_player: float = 2000
@export var max_offset: float = 100
@export var spawn_y_positions: Array[float] = []
@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_count_curve: Curve

var _next_spawn_x: float = 15.0


func _process(_delta: float) -> void:
	if not Game.player:
		return
	if Game.player_distance >= _next_spawn_x:
		_spawn()
		_calc_next_enemy_spawn()


func _spawn() -> void:
	var avail_spawns: Array[float] = []
	avail_spawns.append_array(spawn_y_positions)
	var rand := randf()
	var count := floori(spawn_count_curve.sample(rand))
	for i in count:
		var spawn_height: float = avail_spawns.pick_random()
		avail_spawns.erase(spawn_height)
		var enemy: Node2D = enemy_scenes.pick_random().instantiate()
		enemy.global_position = Game.player.global_position
		enemy.global_position.x += distance_from_player + randf_range(-max_offset, max_offset)
		enemy.global_position.y = spawn_height
		add_child(enemy)


func _calc_next_enemy_spawn() -> void:
	var dist: float = Game.player_distance
	var dist_to_next := maxf(-2.0 ** (dist/800) + 80.0, 20.0)
	_next_spawn_x = Game.player_distance + dist_to_next
	print(_next_spawn_x)
