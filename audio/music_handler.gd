extends Node2D


@export var idle_track: AudioStream = null
@export var active_tracks: Array[AudioStream]

var _current_track := -1
var _is_active := false

@onready var _music_player: AudioStreamPlayer = %MusicPlayer


func _ready() -> void:
	_music_player.finished.connect(_on_track_complete)
	play_idle()
	Game.launch.connect(func(_power: float, _angle: float) -> void: play())
	Game.end_run.connect(play_idle)


func play_idle() -> void:
	if _music_player.playing:
		_music_player.stop()
	_current_track = -1
	_music_player.stream = idle_track
	_music_player.play()
	_is_active = false


func play(index: int = -1):
	if _music_player.playing:
		_music_player.stop()
	
	if index > -1:
		_current_track = index % active_tracks.size()
	else:
		_current_track = randi_range(0, active_tracks.size() - 1)
	
	_music_player.stream = active_tracks[_current_track]
	_music_player.play()
	_is_active = true


func _on_track_complete() -> void:
	if not _is_active:
		_music_player.play()
		return
	play(_current_track + 1)
