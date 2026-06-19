extends Control

func _process(delta):
	var distance_text := "Distance Traveled: " + str(Game.player_distance)
	%Distance_Meter.text = distance_text
	var rpm_text := "RPM: " + str(Game.rpm)
	%RPM_Meter.text = rpm_text
	var monies_text := "Monies: " + str(Game.monies)
	%Monies.text = monies_text
