extends Node3D

@onready var door_vis = $r_point
@onready var swing = false;
@onready var swing_direction = 0;
@onready var base_rotation;
@onready var collider : StaticBody3D = $StaticBody3D
@onready var collider_y : float = 0.0
@onready var audio = $AudioStreamPlayer3D
@export var key_pair : int
@onready var unlock = false
@export var dialogue_string : String 
@export var hide_on_end_of_interact : bool = false
@export var play_audio : bool = true

var swing_state = 0;
var open_int = 100;
var open_timer = 0;
var open_time = 15*60;
var swing_speed = 0.06

# Called when the node enters the scene tree for the first time.
func _ready():
	base_rotation = rotation.y;
	collider_y = collider.global_position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if unlock :
		if swing :
			$Area3D.global_position.y = collider_y - 100.0 
			collider.global_position.y = collider_y - 100.0 
			if swing_state == 0 :
				if play_audio :
					audio.play()
				if swing_direction > 0 :
					swing_state = 1
				else :
					swing_state = 2
			if swing_state == 1 :
				door_vis.rotation.y = move_toward(door_vis.rotation.y,deg_to_rad(base_rotation-90.0),swing_speed)
				if door_vis.rotation.y < deg_to_rad(base_rotation-90.0)+0.01 :
					swing_state = 3
			if swing_state == 2 :
				door_vis.rotation.y = move_toward(door_vis.rotation.y,deg_to_rad(base_rotation+90.0),swing_speed)
				if door_vis.rotation.y > deg_to_rad(base_rotation+90.0)-0.01 :
					swing_state = 3
