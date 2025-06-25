extends Node3D

var light_direction : int = 1 #from which end of the hallway to light up
var light_seq_on : bool = true #internal switch to start turning lights off 
var light_seq_done : bool = true #if the entire on / off cycle is done 
var light_array : Array = [] #our lights to flip on / off
var light_int : int = 0 #which light we're targetting
var ping_pong_pause : float = 10.0 #pause before turning the lights back on / off 

var bad_stuff_array : Array = []
var bad_stuff_load = load("res://entities/level_construction/bad_stuff_collider.tscn")

@onready var timer : Timer = $Timer
@onready var light_sound : AudioStreamPlayer3D = $light_slam_on
@onready var chaser_sound : AudioStreamPlayer3D = $chaser_noise

func _ready() -> void:
	var _lights = $lights.get_children()
	for n in _lights.size():
		var _i = _lights[n]
		light_array.append(_i)
		_i.visible = false
		_i.audio.stop()
		
	for n in light_array.size() : #generate bad stuffs for darkened lights 
		if n != 0 :
			if n != light_array.size()-1:
				var _inst = bad_stuff_load.instantiate()
				add_child(_inst)
				bad_stuff_array.append(_inst)
				_inst.rotation.y = light_array[n].rotation.y
				_inst.scale = Vector3(4.0,8.0,4.0);
				_inst.global_position = light_array[n].global_position
				#DEBUG; REMOVE THE BELOW LINE! 
				#_inst.global_position.y = light_array[n].global_position.y - 200
				_inst.visible = false
	
	#if this works, let's just have the light array auto-cull these two objects beforehand 	
	#bad_stuff_array[0].global_position.y = -200.0
	#bad_stuff_array[light_array.size()-1].global_position.y = -200.0

func _process(delta: float) -> void:
	if $switch_a.trigger == true :
		$switch_a.trigger = false
		if light_seq_done:
			light_int = 0
			$switch_a.audio.play()
			light_direction = 1
			light_seq_on = true
			light_seq_done = false
	if $switch_b.trigger == true :
		$switch_b.trigger = false
		if light_seq_done:
			$switch_b.audio.play()
			light_int = light_array.size()-1
			light_direction = -1
			light_seq_on = true
			light_seq_done = false
	
	if light_seq_done == false :
		if timer.is_stopped() :
			timer.start(1.0)
			
			light_array[light_int].visible = !light_array[light_int].visible
			var _bool = light_array[light_int].audio.is_playing()
			light_array[light_int].audio.set_playing(!_bool)
			light_sound.global_position = light_array[light_int].global_position
			light_sound.play()
			
			#bad stuff colliders & chaser audio
			if light_array[light_int].visible :
				bad_stuff_array[light_int].global_position.y = -200.0
			else :
				#DEBUG; REINSTATE THE BELOW LINE! 
				bad_stuff_array[light_int].global_position.y = light_array[light_int].global_position.y
				if !chaser_sound.is_playing() :
					chaser_sound.play()
				var _vol = chaser_sound.get_volume_linear()
				chaser_sound.set_volume_linear(lerp(_vol,1.0,0.05))
				chaser_sound.global_position = light_array[light_int].global_position
				
			#keeps our end objects from ever going active to prevent bugs 
			#aka so you can enter the maintenance tunnels w/out getting sucked into the floor :V 
			#if light_int == 0: bad_stuff_array[light_int].global_position.y = -200.0
			#if light_int == light_array.size()-1: bad_stuff_array[light_int].global_position.y = -200.0
			
			light_int += light_direction
			
			var _check : int = 0
			if light_int < 0 :
				light_int = light_array.size()-1
				_check = 1
			if light_int == light_array.size():
				light_int = 0
				_check = 1
			
			if _check == 1:
				print("reversing sequence")
				if light_seq_on :
					var _random = randi_range(0,3)
					if _random == 0 : 
						_random = randf_range(-6.0,10.0)
						timer.start(ping_pong_pause+_random)
					else :
						_random = randf_range(0.0,10.0)
						timer.start(ping_pong_pause+_random)
					#timer.start(ping_pong_pause)
					light_seq_on = false
				else :
					light_seq_done = true
					
	else : #turn off chaser volume 
		if chaser_sound.is_playing():
			var _vol = chaser_sound.get_volume_linear()
			chaser_sound.set_volume_linear(lerp(_vol,0.0,0.05))
			if _vol <= 0.0 :
				chaser_sound.stop()
				
