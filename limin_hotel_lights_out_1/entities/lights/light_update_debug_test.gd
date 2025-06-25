extends Node3D

var update_trigger_toggle = true

func _update() -> void:
	if update_trigger_toggle : 
		update_trigger_toggle = false
		print("light updated")
