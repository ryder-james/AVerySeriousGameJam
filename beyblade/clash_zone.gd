extends Area2D


const ClashZone = preload("uid://dsbp3hu7pirey")


@export var parent_rb: RigidBody2D
@export var emit_clash := false

var _invalid_clash_targets: Array[Node2D] = []


func _ready() -> void:
	area_entered.connect(_on_clash_zone_hit)


func _physics_process(_delta: float) -> void:
	if not parent_rb:
		return
	var speed: float = parent_rb.linear_velocity.length()
	var dir: Vector2 = parent_rb.linear_velocity / speed if speed > 0 else Vector2.ZERO
	var distance := speed / Engine.physics_ticks_per_second
	global_position = parent_rb.global_position + dir * distance


func _on_clash_zone_hit(area: Area2D) -> void:
	if not area is ClashZone:
		return
	var hit_entity := area.get_parent()
	if hit_entity.is_in_group(&"Enemy"):
		if hit_entity in _invalid_clash_targets:
			return
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
		get_tree().create_timer(0.5).timeout.connect(
				func(): 
					set_deferred("monitoring", true)
					set_deferred("monitorable", true)
		)
		_invalid_clash_targets.append(hit_entity)
		get_tree().create_timer(2.0).timeout.connect(func(): _invalid_clash_targets.erase(hit_entity))
		if emit_clash:
			Game.clash(parent_rb.rpm_agent, hit_entity.rpm_agent)
