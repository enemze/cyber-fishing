extends Node3D

@export var key_pair : int

@onready var door_vis = $r_point
@onready var swing = false;
@onready var swing_direction = 0;
@onready var base_rotation;
@onready var collider : StaticBody3D = $StaticBody3D
@onready var trigger_zone : Area3D = $Area3D
@onready var obstruction_zone : Area3D = $Area3D2
@onready var collider_y : float = 0.0
@onready var audio = $AudioStreamPlayer3D
@onready var deactivate : bool = false

var swing_state = 0;
var prev_swing_state : int = 0
var open_int = 100;
var open_timer : float = 0.0;
var open_time : float = 15.0*60.0;
var swing_speed = 0.06
var unlock : bool = false
var auto_open_stay_open : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if !is_in_group("unlock_door") :
		unlock = true
	base_rotation = rotation.y;
	collider_y = collider.global_position.y

#to open & turn off via script
# call script _auto_open_stay_open and give it a direction argument 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if unlock == true :
		if swing :
			collider.global_position.y = collider_y - 100.0
			trigger_zone.global_position.y = collider_y - 100.0
			if swing_state == 0 :
				audio.play()
				if swing_direction > 0 :
					swing_state = 1
				else :
					swing_state = 2
			if swing_state == 1 :
				prev_swing_state = 1
				door_vis.rotation.y = move_toward(door_vis.rotation.y,deg_to_rad(base_rotation-90.0),swing_speed)
				if door_vis.rotation.y < deg_to_rad(base_rotation-90.0)+0.01 :
					swing_state = 3
					if auto_open_stay_open:
						swing_state = 4
			if swing_state == 2 :
				prev_swing_state = 2
				door_vis.rotation.y = move_toward(door_vis.rotation.y,deg_to_rad(base_rotation+90.0),swing_speed)
				if door_vis.rotation.y > deg_to_rad(base_rotation+90.0)-0.01 :
					swing_state = 3
					if auto_open_stay_open:
						swing_state = 4
			if swing_state == 3 :
				if is_in_group("unlock_door") :
					deactivate = true
					swing_state = 0
					swing = false
				open_timer += open_int*delta;
				if open_timer > open_time :
					var _check = obstruction_zone.get_overlapping_bodies()
					if _check :
						open_timer = 0.0
						print("door obstructed")
						swing_state = prev_swing_state
					else:
						door_vis.rotation.y = move_toward(door_vis.rotation.y,deg_to_rad(base_rotation),swing_speed)
						if snapped(door_vis.rotation.y,0.001) == snapped(deg_to_rad(base_rotation),0.001) :
							swing_state = 0
							swing = false
							open_timer = 0
			if swing_state == 4:
				deactivate = true
		else :
			if !deactivate :
				collider.global_position.y = collider_y
				trigger_zone.global_position.y = collider_y
				
func _auto_open_stay_open(direction : int) -> void : 
		if auto_open_stay_open == false:
			swing = true
			swing_state = direction 
			auto_open_stay_open = true 
