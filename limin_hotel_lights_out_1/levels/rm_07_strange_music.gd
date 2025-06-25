# NOTE: The functions for the gramopphone are in g_phone_handler

extends Node3D

@export var one_shot : bool = true
var trigger : bool = false
var one_shot_internal : bool = true
var reveals_position_array : Array = []
var on_off_check : bool = false

func _ready() -> void:
	var _reveals = $reveals.get_children()
	for n in _reveals.size(): 
		reveals_position_array.append(_reveals[n].global_position)
		_reveals[n].global_position.y = -200
	
func _process(delta) -> void :
	
 #--------------------------------------------------------
 # light switch handler
#--------------------------------------------------------
	#play audio on press button 
	if trigger :
		trigger = false
		if one_shot_internal :
			$g_phone_handler/Timer.start()
			on_off_check = true
			remove_from_group("show_interact_text")
			$AudioStreamPlayer3D.play()
			var _lights = $lights.get_children()
			for n in _lights.size(): 
				if _lights[n].get_name() == "lamp_trigger" :
					_lights[n].func_on_off()
				else:
					_lights[n].visible = !_lights[n].visible
			var _reveals = $reveals.get_children()
			for n in _reveals.size(): 
				_reveals[n].global_position = reveals_position_array[n]
				
			if one_shot :
				remove_from_group("show_interact_text")
				one_shot_internal = false
