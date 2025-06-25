extends Node3D
#check LOS to player
#adjust associated data accordingly 
@onready var look_cast : RayCast3D = $RayCast3D
@onready var aud_stream : AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var lowpassfilter = load("res://entities/new_audio_effect_low_pass_filter.tres")
@export var target : Node3D
var toggle = true
var update_interval : int = 3
var update : int = update_interval -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	look_cast.add_exception(target)

#maybe change this to only update every few frames instead of EVERY frame 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !toggle :
		#this causes stutering for some reason 
		#update += 1
		#if update == update_interval :
			
			var distance = look_cast.global_position.distance_to(target.global_position)
			look_cast.look_at(target.global_position,Vector3.UP,false);
			look_cast.target_position.z = -distance
			var _check = look_cast.is_colliding()
			
			if _check : # wall
				#aud_stream.volume_db = 0.0
				if AudioServer.get_bus_effect_count(1) == 0 :
					AudioServer.add_bus_effect(1,lowpassfilter,0)
			else : # no wall
				#aud_stream.volume_db = 0.0
				if AudioServer.get_bus_effect_count(1) > 0 :
					AudioServer.remove_bus_effect(1,0)
					
			update = 0

func _toggle() -> void:
	if toggle :
		update = update_interval -1
		$AudioStreamPlayer3D.play()
		toggle = !toggle
	else :
		$AudioStreamPlayer3D.stop()
		toggle = !toggle
