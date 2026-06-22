extends CenterContainer


var _charge_tween: Tween = null

@onready var _progress: TextureProgressBar = %Progress


func charge() -> void:
	if _charge_tween:
		_charge_tween.stop()
	_charge_tween = create_tween()
	_charge_tween.tween_property(_progress, "value", _progress.max_value, 0.1)


func deplete() -> void:
	if _charge_tween:
		_charge_tween.stop()
	_charge_tween = create_tween()
	_charge_tween.tween_property(_progress, "value", 0.0, 0.1)
	_charge_tween.set_ignore_time_scale(true)
