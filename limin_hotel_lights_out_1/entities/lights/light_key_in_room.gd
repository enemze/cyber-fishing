extends Node3D
@export var one_shot : bool = true
var trigger : bool = false
var one_shot_internal : bool = true
var reveals_position_array : Array = []
var on_off_check : bool = false

#how to use:
#drag lights that will be turned on / off into "lights"
#can reach into our prefab lights and flick the audio on / off 
#use "lamp_trigger"
#for other lights, check if null
#draw items to be hidden / revealed into "reveals"
func _ready() -> void:
	var _reveals = $reveals.get_children()
	for n in _reveals.size(): 
		reveals_position_array.append(_reveals[n].global_position)
		_reveals[n].global_position.y = -200


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#play audio on press button 
	if trigger :
		trigger = false
		if one_shot_internal :
			on_off_check = true
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
				#remove_from_group("switch_type_a")
				one_shot_internal = false
