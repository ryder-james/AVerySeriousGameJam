extends CenterContainer


var progress: float = 1.0:
	set = set_progress
var _charge_tween: Tween = null

@onready var _progress_bar: TextureProgressBar = %Progress


func deplete() -> void:
	if _charge_tween:
		_charge_tween.stop()
	_charge_tween = create_tween()
	_charge_tween.tween_property(_progress_bar, "value", 0.0, 0.1)
	_charge_tween.set_ignore_time_scale(true)


func set_progress(new_progress: float) -> void:
	if _charge_tween:
		_charge_tween.stop()
	progress = clamp(new_progress, 0.0, 1.0)
	_progress_bar.value = _progress_bar.max_value * progress
