extends Node2D


@export var left_bg: Node2D = null
@export var right_bg: Node2D = null
@export var stage_colors: Array[Color] = []

var _last_check := 0.0
var _stage := 0
var _advance_stage := false

@onready var _active_bg := left_bg
@onready var _inactive_bg := right_bg


func _ready() -> void:
	modulate = stage_colors[_stage]


func _process(_delta: float) -> void:
	if not Game.player:
		return
	
	var player_pos := Game.player.global_position.x
	var traveled := absf(_last_check - player_pos)
	if traveled >= 16_000:
		_advance_bg()
		_last_check = player_pos


func _advance_bg() -> void:
	_active_bg.global_position.x += 32_000
	
	var temp_bg := _inactive_bg
	_inactive_bg = _active_bg
	_active_bg = temp_bg
	
	if _advance_stage:
		_stage += 1
		_stage %= stage_colors.size()
	_advance_stage = not _advance_stage
	
	modulate = stage_colors[_stage]
