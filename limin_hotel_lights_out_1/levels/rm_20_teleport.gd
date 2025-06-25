extends Node3D

#wait until switch flip 
# light on, and tp to new room location using code from dark maze 
# either TP the player to the starting room, or to a location elsewhere 

var trigger : bool = false
var state : int = 0

var one_shot_internal : bool = true
var reveals_position_array : Array = []
var on_off_check : bool = false

var tp_positional_offset : Vector3
var ref_node : Node3D
var end_target : Node3D

@export var one_shot : bool = true
@export var player : CharacterBody3D
@export var world : Node3D

@onready var switch_audio : AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	var _reveals = $reveals.get_children()
	for n in _reveals.size(): 
		reveals_position_array.append(_reveals[n].global_position)
		_reveals[n].global_position.y = -200

#NOTE: BEFORE YOU CHANGE HOW THIS WORKS 
# currently the way this is set up is that if you walk into the bad_stuff zones, it 
# TPs you back to spawn. this is FINE because it already turns on the lights to the main room
# you don't need to change ANYTHING as technically the spook is DONE once the player 
# clicks the first light 
	
func _process(delta: float) -> void:
	if trigger :
		match state : 
			0: #player has activated the first switch
				_switch_lights()
				trigger = false
				ref_node = $light_target_node_a
				end_target = $light_target_node_b
				tp_positional_offset = ref_node.global_position - player.global_position
				player.global_position = end_target.global_position - tp_positional_offset
				switch_audio.global_position = end_target.global_position
				switch_audio.play()
				$Area3D/CollisionShape3D.global_position.y = -200
				$Area3D/CollisionShape3D2.global_position.y = -200
				state += 1
			1:
				trigger = false
				state += 1
				ref_node = $light_target_node_c
				end_target = $light_target_node_a
				tp_positional_offset = ref_node.global_position - player.global_position
				player.global_position = end_target.global_position - tp_positional_offset
				switch_audio.global_position = end_target.global_position
				switch_audio.play()
				remove_from_group("show_interact_text")
			2:
				pass
			

func _switch_lights() -> void:
	if one_shot_internal :
		on_off_check = true
		#$AudioStreamPlayer3D.play()
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
			one_shot_internal = false
