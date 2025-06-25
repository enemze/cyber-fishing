extends Node3D

var trigger : bool = false
var one_shot_internal : bool = true
var reveals_position_array : Array = []
var on_off_check : bool = false

var furni_array : Array
var open_door_after_update : bool = false
var furni_swap : bool = false
var furni_swap_active : bool =  false

@export var one_shot : bool = true
@export var cardinal : int = 0

@onready var my_door : Node3D = $WallDoorFull1


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
		
	furni_array = [
		$furni_sets/furniture_set_0,
		$furni_sets/furniture_set_1,
		$furni_sets/furniture_set_2
	]
	furni_array[1].global_position.y = -200
	furni_array[2].global_position.y = -200


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#play audio on press button 
	if trigger :
		trigger = false
		if one_shot_internal :
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
				furni_swap_active = true
				open_door_after_update = true
				remove_from_group("switch_type_a")
				one_shot_internal = false
				
func _update() -> void :
	if furni_swap_active :
		if furni_swap :
			var _start : int = 0
			if open_door_after_update : 
				_start = 1
			var _randi = randi_range(_start,furni_array.size()-1)
			for n in furni_array.size() :
				furni_array[n].visible = false
				furni_array[n].global_position.y = -200
			furni_array[_randi].visible = true
			furni_array[_randi].global_position.y = 0.0
			#active our CoT TV; note, if this doesn't work, the value is likely 0 not 2 
			if _randi == 2:
				$furni_sets/furniture_set_2/CoT_TV.active = true
			else:
				$furni_sets/furniture_set_2/CoT_TV.active = false
			furni_swap = false
	if open_door_after_update :
		my_door._auto_open_stay_open(1)
		open_door_after_update = false

func _on_timer_timeout() -> void:
	furni_swap = true
