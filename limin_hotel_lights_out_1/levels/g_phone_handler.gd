extends Node3D

var trigger : bool = false
var active : bool = false
@onready var dancer : Node3D = $"../dancer_1"
@onready var main : Node3D = $"../../.."
@onready var gramo_audio : Node3D = $gramo_audio
@onready var bad_stuff : Node3D = $BadStuffCollider
var noise_active : bool = false
var blast_timer : float = 0.0
var b_time_base : float = 10.0
var blast_time : float = b_time_base

#NOTE : If you want to gamify this, have it play music and keep the dancer in this room 
# then do the YBR thing when the timer runs OUT, freeing the dancer to roam 
# however, I kind of prefer it being a one-off spook, yannow 

#NOTE : currently this is on a timer, but later I would change it to be part of the auto-spook system 
#NOTE : possibly make the YBR audio global, with the noise / crackle being 3D to guide the player 
#NOTE : set up some special functions to disable this if in maze, for example 

func _ready() -> void :
	bad_stuff.visible = false
	
func _process(delta) -> void :
#----------------------------------------------------------------------------------------
#debug trigger 
#----------------------------------------------------------------------------------------
	if Input.is_action_just_pressed("debug_g") :
		pass
		#$Timer.stop()
		#active = false
		#activate_spook()
#----------------------------------------------------------------------------------------
#debug trigger 
#----------------------------------------------------------------------------------------
	#check if debug #if debug yes, turn on phnograph 
	#from there, set up checks from main, etc 
	#does main give it's children a "progenitor" check? 
	#might want to do that so things are easier 
	
	if trigger :
		if active :
			dancer.active = false
			#maybe give the dancer a delayed sigh 
			$Timer.start()
			$AudioStreamPlayer.play()
			gramo_audio._toggle()
			active = false
			bad_stuff.global_position.y = -200.0
			blast_quit()
		trigger = false 
	else :
		pass
		
	if active:
		if $noise_timer.is_stopped():
			if !noise_active :
				$noise_timer.set_wait_time(10.0 + randf()*10.0)
				$noise_timer.start()
		
	#ease in / ease out loud noise 
	if noise_active :
		blast_timer += 1.0*delta
		if fmod(floor(blast_timer*10.0),7.0) == 0.0 :
			$LOUD_NOISE.set_pitch_scale(randf_range(0.6,1.4))
			
		if blast_timer > blast_time :
			noise_active = false
			$LOUD_NOISE.set_volume_linear(0.0)
			blast_timer = 0.0
			blast_time = b_time_base + (randf()*b_time_base);
			$LOUD_NOISE.stop()
			$noise_timer.start()

			
		

#this function is triggered by the auto-spook system 
func activate_spook() -> void:
	#this is a tad convuluted
	if !active :
		#this timer is triggered in the parent ROOM node 
		if $Timer.is_stopped() :
			$Timer.start()
			bad_stuff.global_position.y = 0.0
			print("gramo audio on")
			dancer.active = true
			active = true
			gramo_audio._toggle()
			
func noise_blast() -> void:
	$LOUD_NOISE.play(randf()*30.0)
	$LOUD_NOISE.set_volume_linear(6.0)
	noise_active = true
	
func blast_quit() -> void:
	$LOUD_NOISE.stop()
	$LOUD_NOISE.set_volume_linear(0.0)
	noise_active = false
	blast_timer = 0.0
	

func _on_noise_timer_timeout() -> void:
	if active :
		noise_blast()
		
