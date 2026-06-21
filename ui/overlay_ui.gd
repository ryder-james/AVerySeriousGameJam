extends Control


func _process(_delta: float) -> void:
	if not Game.player:
		return
	
	var distance_text := "Distance Traveled: %s" % Game.player_distance
	%Distance_Meter.text = distance_text
	var rpm_text := "RPM: %s" % roundi(Game.player.rpm_agent.rpm)
	%RPM_Meter.text = rpm_text
	var monies_text := "Monies: %s" % Game.monies
	%Monies.text = monies_text
