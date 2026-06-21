extends Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = get_parent().global_position
	global_position -= size * 0.5
	text = str(roundi(get_parent().rpm_agent.rpm))
