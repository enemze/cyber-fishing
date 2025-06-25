extends Node3D

@onready var door_vis = $r_point
@onready var swing = false;
@onready var swing_direction = 0;
@onready var base_rotation;
@onready var collider : StaticBody3D = $StaticBody3D
@onready var collider_y : float = 0.0
@onready var audio = $AudioStreamPlayer3D
@export var cardinal : int

@export var my_switch : Node3D
@export var my_light : MeshInstance3D

var on_off_check = false
var update_check = 0

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
	
	if my_switch.emit :
		if update_check == 0 :
			update_check = 1
			my_switch.emit = false
		if update_check == 2:
			update_check = 3
			my_switch.emit = false
			on_off_check = true
			#also probably hide swtich collider 
			swing = true
			swing_state = 3
		
	if update_check == 2 :
		door_vis.rotation.y = deg_to_rad(base_rotation-90.0)+0.01
		collider.global_position.y = collider_y - 100.0
		$Area3D.global_position.y = collider_y - 100.0
		
	
	if swing :
		collider.global_position.y = collider_y - 100.0
		$Area3D.global_position.y = collider_y - 100.0
		if swing_state == 0 :
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
		if swing_state == 3 :
			open_timer += open_int*delta;
			if open_timer > open_time :
				door_vis.rotation.y = move_toward(door_vis.rotation.y,deg_to_rad(base_rotation),swing_speed)
				if snapped(door_vis.rotation.y,0.001) == snapped(deg_to_rad(base_rotation),0.001) :
					swing_state = 0
					swing = false
					open_timer = 0
	else :
		if update_check != 2 :
			collider.global_position.y = collider_y
			$Area3D.global_position.y = collider_y
		
func _update() -> void:
	if update_check == 1 :
		my_light.func_on_off()
		update_check = 2
