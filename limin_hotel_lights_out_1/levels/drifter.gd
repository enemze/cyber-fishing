extends Node3D

var spawn_array : Array = []
var active : bool = false
var wait_mode : bool = false
var check_LOS : bool = false
var has_LOS : bool = false
var spd : float = 3.0
var anim_int : float = 0.0
var base_y : float = 0.0
var spawn_position : Vector3 
var jump : bool = false
var jump_dist : float = 5.0

@onready var look_cast : RayCast3D = $RayCast3D

@export var target : CharacterBody3D
@export var main : Node3D

func _ready() -> void :
	spawn_position = global_position
	look_cast.add_exception(target)
	var _array =  $"../spawn_positions".get_children(false)
	for n in _array.size() :
		var _i = _array[n]
		spawn_array.append(_i)

#make it make audio that gets louder as it gets closer 

#note: position setting before active trigger is set via MAIN
func _process(delta) -> void :
	if active :
		anim_int += 1.0*delta
		if anim_int > 360.0 :
			anim_int = 0.0
		$MeshInstance3D.position.y = base_y + (sin(anim_int)*0.5)
		$MeshInstance3D.rotation.y = anim_int 
		
		if wait_mode :
			if has_LOS :
				wait_mode = false
		else :
			if has_LOS :				
				var _dist = global_position.distance_to(target.global_position)
				if _dist < 4.0 : main.static_vis_active = 2.0
				if _dist > 1.0 :
					if jump :
						var _j_dist : float = randf_range(jump_dist-1.0,jump_dist)
						var _dot = global_position.dot(target.global_position)
						_dot = _dot/abs(_dot)
						if _dot > 0 :
							global_position.x = move_toward(global_position.x, target.global_position.x,_j_dist)
						else :
							global_position.z = move_toward(global_position.z, target.global_position.z,_j_dist)
						$jump_timer.set_wait_time(randf_range(0.5,2.0))
						jump = false
						#spare code for later
						#global_position.y = move_toward(global_position.y, target.global_position.y+1.0,spd*delta)
				
			else :
				active = false
				wait_mode = true
				global_position.y -= 200

func _physics_process(delta: float) -> void:
	if check_LOS :
		var distance = look_cast.global_position.distance_to(target.global_position)
		var _target_pos = target.global_position
		look_cast.look_at(_target_pos,Vector3.UP,false);
		look_cast.target_position.z = -distance
		var _check = look_cast.is_colliding()
		if _check == true :
			has_LOS = false
		else :
			has_LOS = true
		check_LOS = false
	

func _on_timer_timeout() -> void:
	if active :
		check_LOS = true


func _on_jump_timer_timeout() -> void:
	jump = true
