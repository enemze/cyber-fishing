extends Node3D

var mann_array : Array = []
var mann_ary_int : int = 0
var target : Node3D
var active : bool = false
var collider_array : Array = []
var collider_int_check : int = 0
var collider_int : int = 0
var collider_confirm : bool = false
@export var player : CharacterBody3D
var mode : int = 0 # 0 = no dot check, 1 = dot check
var dot_thresh : float = 1.15 #was 1.0 #larger = more out of view 

#check if player is in room 
#if yes, check each mannequin's dot towards player 
#based on such, look at player or don't look at player 

func _ready() -> void:
	collider_array = [$outside_room,$main_tunnel,$in_room]
	var _manns = $mannequins.get_children(false)
	for n in _manns.size(): 
		var _i = _manns[n]
		mann_array.append(_i)
	
func _process(delta: float) -> void:
	_check_colliders()
	if active :
		var _base_rotation : Vector3 = mann_array[mann_ary_int].rotation
		mann_array[mann_ary_int].look_at(target.global_position)
		
		if mode == 0:
			mann_array[mann_ary_int].rotation.x = 0.0 #just reset our X & z axis so we don't tilt
			mann_array[mann_ary_int].rotation.z = 0.0
		
		if mode == 1 :
			var _dot = target.global_transform.basis.z.angle_to(-mann_array[mann_ary_int].global_transform.basis.z)
			if _dot < dot_thresh : #if the player is looking at us, reset 
				mann_array[mann_ary_int].rotation = _base_rotation
			else : 
				mann_array[mann_ary_int].rotation.x = 0.0 #just reset our X & z axis so we don't tilt
				mann_array[mann_ary_int].rotation.z = 0.0
			
		mann_ary_int += 1
		if mann_ary_int > mann_array.size()-1 :
			mann_ary_int = 0
			

func _check_colliders() -> void:
	if collider_array[collider_int].has_overlapping_bodies() :
		collider_confirm = true
		match collider_int :
			0 : #outside front door 
				target = $"../WallDoorFull1"
				mode = 0
			1 : #maintenance tunnel
				target = $"../WallDoorAjar1"
				mode = 0
			2 : #inside room
				target = player
				mode = 1
	collider_int += 1
	if collider_int > collider_array.size()-1:
		if collider_confirm :
			active = true
		else :
			active = false
		collider_confirm = false
		collider_int = 0
		
