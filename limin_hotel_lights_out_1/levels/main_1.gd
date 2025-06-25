extends Node3D

@export var pause_menu : Node3D

#HUD elements
@onready var load_screen : Control = $main_handler/HUD/Control/LoadingScreen
@onready var overhead_text : RichTextLabel = $main_handler/HUD/Control/RichTextLabel
@onready var vision_fader : ColorRect = $main_handler/HUD/Control/fader_rect
@onready var blink_fader : AnimatedSprite2D = $main_handler/HUD/Control/blink_sprite

@onready var load_timer : Timer = $main_handler/load_timer #replace this with an actual done loading signal
@onready var generic_timer : Timer = $main_handler/generic_timer
var fixed_toggle = false;
@onready var player = $player_TPS
@onready var behind_player = $player_TPS/Head/behind_player
@onready var ceiling = $ceiling
@onready var elevator_exit_check = $main_handler/near_elevator
@onready var on_elevator_check = $main_handler/on_elevator

@onready var kill_plane = $main_handler/kill_plane
@onready var facing_check : Node3D = $main_handler/facing_check
var is_facing_center : bool = false

var elevator_door_state : bool = false #true = open, false = closed 
var overhead_alpha = 2.0
var text_pos = Vector2.ZERO
var tutorial_complete = 0
var opening_sequence : int = 0

var location_check : int = 0
var player_location : int = 0 
#0 = in corridor 
#1 = not in corridor 
#2 = in dark maze 
#3 = maintenance (specifically the "turn off bad stuff skybox" maintenance

var fader_alpha : float = 2.0 #set this to 2.0 once we're done debugging 
var fade_val : float = 0.3
var fade_dir : float = -1.0 #set this to -1.0 once we're done debugging 
var fade_in_out : int = 0
var fade_timer : float = 0.0
var crossfade = false
var crossfade_step = 0;
var fade_token = -1
signal fade_state(in_or_out)
signal sig_fade_clear

var blink_fade_timer : float = 0.0
var blink_state : bool = false

var on_off_check : Array = []
var on_off_previous : int = 0
var cross_corridor_updates : Array = []
var cc_update_colliders : Array = []
var cc_update_int : int = 0

#there might be a better way to handle this, but this oughta work 
# from closest to elevator to furthest
var end_sequence : int = -1 
var end_sequence_lights = []
var end_seq_state : int = 0
@onready var end_seq_collider : StaticBody3D = $main_handler/end_seq_collider

#sink into floor & death behavior 
var in_bad_stuff : bool = false
var in_bad_state : int = 0
var bad_stuff_y_offset : float = 0.0
@onready var floor_sink : StaticBody3D = $floor
var floor_collision_layer : int = 0
var die_fall_thresh : float = -0.6
var rise_reset : bool = true
var rise_reset_thresh : float = 1.51 #i think 1.65 is good 
var sink_speed : float = 60.0
var sink_speed_base : float = sink_speed
var sink_lateral_spd = 1.0;
@onready var floor_sink_skybox : Node3D = $floor_sink_skybox
var sink_skybox_follow : bool = true
var sink_and_die : bool = false
var sink_audio_lock : bool = false
var sink_skyb_y : float = 0.0
@onready var into_maint : Area3D = $main_handler/into_maintenance
@onready var outof_maint : Area3D = $main_handler/outof_maintenance

@onready var respawn_point : Node3D = $respawn_point
@onready var default_respawn : Node3D = $respawn_point
var respawn_position : Vector3

var corridor_lights : Array = []
var corridor_light_target : int = 0
var flicker_g_position : Vector3 = Vector3.ZERO
@onready var flicker_spook_light : Node3D = $main_handler/spooks/flicker_light_base_2
var cl_pause_check : bool = false

#spook & various spook controls 
var spook_type_max : int = 7 #MANUALLY UPDATE THIS 
var spook_thresholds : Array = [
0, #light flicker 
0, #hadex anomaly (was light flicker type 2)
0, #gramophone 
0, #drifter 
0, #hall mannequin
0, #hello
0, #notes 
0, #pipes
]

enum spook {flicker,anomaly,gramophone,drifter,hallmann,hello,notes,anomaly_aggro,pipes}

var auto_spook : bool = false
var spook_type : int = 0
var spook_state : int = 0
var spook_target : Node3D
var flicker_spook_1 :bool = false
var flicker_spook_2 :bool = false
var hello_spook : bool = false
var hello_spook_node : Node3D
var note_target_int : int = 0 
@onready var note_spook : Node3D = $main_handler/spooks/note_spook_spawns/InteractableItemContainer
var note_spawn_locations : Array = []
var note_dialogue : Array = [ #make these our dialogic targets 
"res://dialogic/timelines/story_notes/tml_side_story_02.dtl",
"res://dialogic/timelines/story_notes/tml_side_story_04.dtl",
"res://dialogic/timelines/story_notes/tml_side_story_05.dtl",
"res://dialogic/timelines/notes/tml_note_spook_0.dtl"
]

@onready var drifter : Node3D = $drifter_holder/drifter

var story_dialogue_array : Array = [
	"res://dialogic/timelines/story_notes/tml_story_01.dtl",
	"res://dialogic/timelines/story_notes/tml_story_02.dtl",
	"res://dialogic/timelines/story_notes/tml_story_03.dtl",
	"res://dialogic/timelines/story_notes/tml_story_04.dtl",
	"res://dialogic/timelines/story_notes/tml_story_05.dtl",
]
var story_increment : int = 0

@onready var generic_col_a : Area3D = $main_handler/generic_collider_a
@onready var general_audio : AudioStreamPlayer = $main_handler/general_audio
@onready var general_audio_3D : AudioStreamPlayer3D = $main_handler/general_audio_3D

#DEBUG:
var _debug : bool = false 
var _debug_toggle : bool = true
@onready var debug_text : RichTextLabel = $main_handler/HUD/Control/debug_text_0

enum update_groups {NORTH, SOUTH, EAST, WEST}

signal player_died 

@export var anomaly : Node3D
@onready var drifter_static : TextureRect = $main_handler/HUD/Control/drifter_static
var static_vis_active : float = 0.0
@export var drifter_noise : NoiseTexture2D 

@onready var pipe_spook_vis : Array = [
	$"../whiteboxing/props/pipes",
	$"../whiteboxing2/props/pipes",
	$"../whiteboxing3/props/pipes",
	$"../whiteboxing4/props/pipes"
]

var pause_mode : bool = false
var pause_rotation_save : Vector3 = Vector3.ZERO

var version : int = 061520255

var save_data : Dictionary = {
	"version" : version,
	"master_audio" : 1.0,
	"fullscreen" : false,
	"on_off_check" : []
	}

var blank_data : Dictionary 

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$"../debug_light".visible = false
	load_screen.visible = true
	overhead_text.visible = true
	vision_fader.visible = true
	blink_fader.visible = true
	text_pos = overhead_text.position
	ceiling.visible = true;
	$floor.visible = true;
	end_sequence_lights = [
		$"../lights_other/flour_light_base_4",
		$"../lights_other/flour_light_base_2",
		$corridor_lights/flour_light_base_14,
		$corridor_lights/flour_light_base_13,
		$corridor_lights/flour_light_base_15,
		$corridor_lights/flour_light_base_16
	]
	
	#our colliders for our corridor update blocks
	cc_update_colliders = [
		$main_handler/corridor_update_colliders/north,
		$main_handler/corridor_update_colliders/south,
		$main_handler/corridor_update_colliders/east,
		$main_handler/corridor_update_colliders/west
	]
	
	note_spawn_locations = [
		$main_handler/spooks/note_spook_spawns/south,
		$main_handler/spooks/note_spook_spawns/north,
		$main_handler/spooks/note_spook_spawns/west,
		$main_handler/spooks/note_spook_spawns/east
	]
	
	note_target_int = -1
	note_spook.trigger = true
	
	#our list for our corridor updates
	var _list = []
	_list = $room_handlers.get_children(false)
	for n in _list.size() :
		if _list[n].is_in_group("room_update") :
			var _int = _list[n]
			cross_corridor_updates.append(_int)
		if _list[n].is_in_group("on_off_check") :
			var _int = _list[n]
			on_off_check.append(_int)
			
	spook_thresholds  = [
	0, #light flicker 
	int((floor(float(on_off_check.size())*0.5))), #hadex anomaly (was light flicker type 2)
	int((floor(float(on_off_check.size())*0.5))), #gramophone 
	int((floor(float(on_off_check.size())*0.4))), #drifter 
	int((floor(float(on_off_check.size())*0.3))), #hall mannequin
	int((floor(float(on_off_check.size())*0.4))), #hello
	int((floor(float(on_off_check.size())*0.3))), #notes 
	int((floor(float(on_off_check.size())*0.8))), #anomaly aggro
	int((floor(float(on_off_check.size())*0.6))), #pipes
	]
			
	_list = $corridor_lights.get_children(false)
	for n in _list.size() :
		if _list[n].get_name() != "flicker_light_base_1" :
			var _int = _list[n]
			corridor_lights.append(_int)
	
	floor_collision_layer = floor_sink.get_collision_layer()
	respawn_position = respawn_point.global_position
	sink_skyb_y = floor_sink_skybox.global_position.y
	
	#fullscreen
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	_resize_UI()
	
	$entities/hall_mannequin_special.global_position.y = -200.0
	
	drifter_static.modulate.a = 0.0
	
	for n in pipe_spook_vis.size() :
		pipe_spook_vis[n].visible = false
		
	#--------------------------------------------------------------
	#save & load stuff 
	#--------------------------------------------------------------
	#(possibly move this elewhere so it's not all done in the ready event)
	for n in on_off_check.size() :
		var _int : bool = false
		save_data.on_off_check.append(_int)
	
	blank_data = save_data.duplicate()
	
	#clean our save data if wrong version. this is JUST to make our lives easier 
	#change this later to append new save data 

	if !FileAccess.file_exists("user://savegame.json") :
		_save_game()
	else :
		_load_game()
		
	if save_data.version != version :
		print("new version detected, erasing save data")
		save_data = blank_data.duplicate()
		print(save_data)
		_save_game()

	_update_load_file()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#----------------------------------------------------------------------------------------
#debug trigger 
#----------------------------------------------------------------------------------------
	
	# change this to whatever activation value we need 
	if Input.is_action_pressed("debug_k") :
		#_debug = true
		opening_sequence = 6
		tutorial_complete = 2
		$entities/ElevatorDoors1/AnimationPlayer.play("open")
		$room_handlers/rm_0_tutorial.trigger = true
		player.global_position = $debug/debug_spawn.global_position
		for n in player.key_array.size() :
			player.key_array[n] = true
	
	if Input.is_action_just_pressed("debug_g") :
		pass
		#pass
		#for n in player.key_array.size() :
			#player.key_array[n] = true
			#anomaly.active = true
			#flicker_spook_1 = true
		#_hello_spook_type()
		#_pipes_spook_type()
		#_debug = true
	if _debug_toggle :
		match player_location :
			0 : #hallway
				debug_text.text = "dbg_location: hallway"
			1 : #not hallway
				debug_text.text = "dbg_location: not hallway"
			2 : #nathroom maze
				debug_text.text = "dbg_location: nathroom maze"
			3 : #maintenance under
				debug_text.text = "dbg_location: maintenance under"
	else :
		debug_text.text = ""

		
#----------------------------------------------------------------------------------------
#quest text 
#----------------------------------------------------------------------------------------
	overhead_alpha -= 1.0*delta
	overhead_alpha = clamp(overhead_alpha,0.0,999.0)
	overhead_text.modulate = Color(1.0, 1.0, 1.0, overhead_alpha)
	overhead_text.position = Vector2(randi_range(-1,1),randi_range(-1,1)) + text_pos
	#$CameraTps.global_position = $PlayerV1.global_position
	#$CameraTps.global_position.y += 1.0;
	#$CameraTps.rotation = $PlayerV1.rotation
	
	#if Input.is_action_just_pressed("debug_g"):
		#fixed_toggle = !fixed_toggle;
#----------------------------------------------------------------------------------------
#floor sink sky box movement 
#----------------------------------------------------------------------------------------
	if sink_skybox_follow :
		floor_sink_skybox.global_position.y = sink_skyb_y
		floor_sink_skybox.global_position.x = player.global_position.x
		floor_sink_skybox.global_position.z = player.global_position.z
	else :
		floor_sink_skybox.global_position.y = -200.0
	
	if fixed_toggle :
		pass
		#$CameraTps.global_position = $fixed_point.global_position
		#$CameraTps.look_at(player.global_position,Vector3.UP,false)
	else :
		pass
		#attach camera to player 
		#$CameraTps.global_position = player.global_position
		#$CameraTps.global_position.y = player.global_position.y+0.75;
		#$CameraTps.rotation.y = player.rotation.y
		#$CameraTps.rotation.x += deg_to_rad(-30.0);

	if player.area_update != null :
			in_bad_stuff = true
	else :
		if !sink_and_die :
			if player.in_bad_stuff == true:
				rise_reset = true
		in_bad_stuff = false
			
	_fade_handler(delta)
	
	_blink_handler(delta)
				
	_in_bad_stuff(delta)
	
	_swap_to_pause_menu()
	
	_auto_spook(delta)
	
	_static_vis(delta)
	
	if opening_sequence > 0 :
		match opening_sequence :
			1 :
				generic_timer.start(3.0)
				opening_sequence += 1
			2 :
				if generic_timer.is_stopped() :
					general_audio.play()
					opening_sequence += 1
			3: 
				if general_audio.is_playing() == false :
					generic_timer.start(1.0)
					opening_sequence += 1
			4:
				if generic_timer.is_stopped() :
					$entities/ElevatorDoors1/AnimationPlayer.play("open")
					opening_sequence += 1
			5:
				pass
	
	if end_sequence > -1 :
		end_sequence_update()
		
	if hello_spook == true :
		if general_audio_3D.is_playing() :
			general_audio_3D.global_position = hello_spook_node.global_position
		else:
			hello_spook = false
			
	if flicker_spook_1 :
		_light_flicker_spook_type_1()
		
	if flicker_spook_2 :
		_light_flicker_spook_type_2()
	
			

	
func _on_load_timer_timeout():
	load_screen.visible = false
	opening_sequence = 1
	if _debug_toggle :
		pass
		#$entities/ElevatorDoors1/AnimationPlayer.play("open")

func _auto_spook(delta) -> void:
	if auto_spook :
		if end_sequence < 0 :
			if tutorial_complete > 0 :
				if spook_type == 0 :
					print("auto_spook: light flicker")
					if !flicker_spook_1 :
						flicker_spook_1 = true
				if spook_type == 1 : #replace this or do something else w/ it 
					print("auto_spook: light flicker")
					if !flicker_spook_1 :
						flicker_spook_1 = true
				if spook_type == 2 :
					if on_off_previous > spook_thresholds[spook.gramophone] :
						print("auto_spook: gramophone")
						_gramophone_spook_type()
				if spook_type == 3 :
					if on_off_previous > spook_thresholds[spook.drifter] :
						print("auto_spook: drifter")
						_drifter_spook_type()
				if spook_type == 4 :
					if on_off_previous > spook_thresholds[spook.hallmann] :
						print("auto_spook: corridor mannequin")
						_corridor_mann_spook_type()
				if spook_type == 5 :
					if on_off_previous > spook_thresholds[spook.hello] :
						print("auto_spook: hello")
						_hello_spook_type()
				if spook_type == 6 :
					if on_off_previous > spook_thresholds[spook.notes] :
						print("auto_spook: notes")
						_notes_spook_type()
				if spook_type == 7 :
					if on_off_previous > spook_thresholds[spook.pipes] :
						print("auto_spook: pipes")
						_pipes_spook_type()
						
				auto_spook = false
			else :
				auto_spook = false
		else :
			auto_spook = false

func _in_bad_stuff(delta) :
	if in_bad_stuff :
		player.play_IBS_audio = true
		player.in_bad_stuff = true
		if static_vis_active > 0.0 : player.IBS_mode = 1 #set audio to static 
		else :player.IBS_mode = 0
		floor_sink.set_collision_layer(0)
		player.fall = 0.0 #gravity
		player.spd = move_toward(player.spd,sink_lateral_spd,0.2) #bs_spd
		player.velocity.y = -sink_speed*delta
		rise_reset = true
		#if sinking, play some sort of weird audio. static?
		#if below floor, play some sort of muffled audio. ocean audio?
		if player.global_position.y < bad_stuff_y_offset + die_fall_thresh : 
			sink_and_die = true
	else :
		if player.global_position.y < 0.0 :	bad_stuff_y_offset = -3
		else :	bad_stuff_y_offset = 0.0
		if rise_reset :
			sink_speed = sink_speed_base
			floor_sink.set_collision_layer(0)
			player.fall = 0.0 #gravity
			player.spd = move_toward(player.spd,sink_lateral_spd*2.0,0.1) #bs_spd
			player.velocity.y = (sink_speed*1.5) *delta
			if player.global_position.y > rise_reset_thresh + bad_stuff_y_offset : 
				if !sink_audio_lock :
					player.play_IBS_audio = false
				player.in_bad_stuff = false
				floor_sink.set_collision_layer(floor_collision_layer)
				rise_reset = false
				player.fall = player.gravity
				player.spd = player.bs_spd
				player.velocity.y = 0.0
	if sink_and_die :
		player.play_IBS_audio = true
		if static_vis_active > 0.0 : player.IBS_mode = 1 
		else :player.IBS_mode = 0
		sink_audio_lock = true
		blink_fade_timer = 2.0
		player.velocity.y = -sink_speed *delta
		if blink_state:
			sink_and_die = false
			rise_reset = false
			in_bad_stuff = false
			#show some sort scratchy jump, sorta like the dialogue popups in 
			#paperhead
			_respawn_player()
			floor_sink.set_collision_layer(floor_collision_layer)
		
func _respawn_player():
	# NOTE: you moved the IBS lock and audio to the blink animation function below 
	player_died.emit()
	player.global_position = respawn_position
	player.rotation.y = respawn_point.global_rotation.y
	player.fall = player.gravity
	player.spd = player.bs_spd
	player.velocity.y = 0.0
	drifter.active = false
	drifter.global_position = drifter.spawn_position

func _kill_plane_check() -> void:
	if player.global_position.y < kill_plane.global_position.y :
		in_bad_stuff = true

#our update loop
func _on_update_timer_timeout() -> void:
	#there's likely a better wya of handling this, but it works for now
	#we likely need to make a state machine later 
	if $corridor_lights.visible == true :
		if tutorial_complete == 0 :
			tutorial_complete = 1
	
	if tutorial_complete == 0 :
		overhead_alpha = 2.0
		
	if tutorial_complete == 1 :
		$entities/ElevatorDoors1/AnimationPlayer.play("close")
		tutorial_complete = 2
		
	#----------------------------------------------------------------------------------------
	#"center facing" updates
	#----------------------------------------------------------------------------------------
	facing_check.look_at(player.global_position)
	var _dot = player.global_transform.basis.z.angle_to(-facing_check.global_transform.basis.z)
	if _dot < 1 :
		is_facing_center = true
	
	#----------------------------------------------------------------------------------------
	#"cross level" updates
	#----------------------------------------------------------------------------------------
	#for when the player is on the other side of the map and something needs ot get updated 
	if tutorial_complete > 1 :
		if cc_update_colliders[cc_update_int].has_overlapping_bodies() :
			location_check += 1
			player_location = 0
			for n in cross_corridor_updates.size() :
				if cross_corridor_updates[n].cardinal == cc_update_int :
					cross_corridor_updates[n]._update()
		
		cc_update_int += 1
		if cc_update_int > cc_update_colliders.size()-1 :
			cc_update_int = 0
			#set player location data 
			if location_check == 0:
				if player_location != 3:
					if player_location != 2:
						player_location = 1
			location_check = 0
	
	# if player trying to get on elevtor, check if all lights are on
	#----------------------------------------------------------------------------------------
	#on / off "completion" updates 
	#----------------------------------------------------------------------------------------
	var _size = on_off_check.size()
	var _int = 0
	
	if elevator_exit_check.has_overlapping_bodies() :
		#you should PROBABLY move the update groups behavior into here instead of having it split
		#between this and the update groups node like so
		for n in _size :
			if on_off_check[n].on_off_check == true :
				_int += 1
		if _debug :
			_int = _size
		if _int == on_off_check.size() :
			if elevator_door_state == false :
				elevator_door_state = true
				$entities/ElevatorDoors1/AnimationPlayer.play("open");
				print("all lights off, opening door")
		else :
			overhead_alpha = 2.0
			#print("you need to turn on more lights")
			
	#HADEX TOGGLE CHECK
		#check number of on / offs active. if half active, release the hadex anomaly	
	if on_off_previous > spook_thresholds[spook.anomaly] :
		if anomaly.active == false:
			print("hadex anomaly active")
			anomaly.active = true
		if on_off_previous > spook_thresholds[spook.anomaly_aggro] :
			if anomaly.mode == 0 :
				print("hadex anomaly aggro mode active")
				anomaly.mode = 1
				anomaly.state = 0
		
		
	#disable skybox if going into maint 
	#NOTE: you gave each of these MULTIPLE colliders. You probably don't want these running 
	#every single frame. 
	if into_maint.has_overlapping_bodies() :
		player_location = 3
		sink_skybox_follow = false
	if outof_maint.has_overlapping_bodies() :
		player_location = 0
		sink_skybox_follow = true

	on_off_update()

#----------------------------------------------------------------------------------------

func _blink_handler(delta) :
	if blink_fade_timer > 0.0 :
		blink_fade_timer -= delta * 1.0
		if blink_fader.frame != 0 :
			if blink_fader.is_playing() == false :
				blink_fader.play_backwards("default")
	else :
		if blink_fader.frame != 7 :
			if blink_fader.is_playing() == false :
				blink_fader.play("default")
				sink_audio_lock = false
				player.play_IBS_audio = false
	if blink_fader.frame == 0 :
		blink_state = true
	else :
		blink_state = false

func _fade_handler(delta):
	if(fade_timer > 0.0):
		fader_alpha += (fade_val * delta) #fade to black
		fade_timer -= (fade_val*delta)
	else :
		if(fader_alpha == 1.0):
			sig_fade_clear.emit()
		fader_alpha -= (fade_val * delta)
	fader_alpha = clamp(fader_alpha,0.0,1.0);
	fade_timer = clamp(fade_timer,0.0,999.0);
	if(fader_alpha == 1.0):
		fade_state.emit(0)
	var m_color = Color(0.0,0.0,0.0,fader_alpha)
	vision_fader.set_color(m_color)
	
func _static_vis(delta) -> void: #also needs to change the static offset 
	if static_vis_active > 0.0 :
		static_vis_active -= 2.0*delta
		drifter_static.modulate.a += 1.0*delta
		drifter_static.modulate.a = clamp(drifter_static.modulate.a,0.0,1.0)
		drifter_noise.noise.offset.x = randi_range(0,360)
		drifter_noise.noise.offset.y = randi_range(0,360)
	else :
		if drifter_static.modulate.a > 0.0 :
			drifter_noise.noise.offset.x = randi_range(0,360)
			drifter_noise.noise.offset.y = randi_range(0,360)
			drifter_static.modulate.a -= 1.0*delta
			
	
#check what has been turned on / off and if all are ON, then check if player is on elevator 
#if yes, start end sequence 
func on_off_update() -> void:
	var _size = on_off_check.size()
	var _int = 0
	for n in _size :
		if on_off_check[n].on_off_check == true :
			_int += 1
			
	if _debug :
		_int = _size
		
	if on_off_previous != _int :
		on_off_previous = _int
		print("on_off_check: " + str(_int) + " out of " + str(_size) + " lights turned on.")
		_update_save_file()
		_save_game()
		
	if _int == _size:
		if on_elevator_check.has_overlapping_bodies() :
			end_sequence_start()
		else :
			overhead_alpha = 2.0
			overhead_text.text = "[center]GET TO THE ELEVATOR"
	else :
		pass

#can also use this to set other variables when the sequence begins 
func end_sequence_start() -> void: 
	if end_sequence == -1 :
		$corridor_lights/flour_light_base_1.visible = false
		print("started end sequence")
		end_seq_collider.global_position.y = 2.0
		end_sequence = 0
		$main_handler/end_sequence_timer.start()
		
# end sequence state machine 
func end_sequence_update() -> void :
	match end_seq_state :
		0 : #wait for lights to turn off one by one 
			var _size = end_sequence_lights.size()
			if end_sequence == _size-1 :
				end_seq_state += 1
		1 : #close elevator doors, cut off noise 
			$entities/ElevatorDoors1/AnimationPlayer.play("close")
			end_seq_state += 1
			generic_timer.set_wait_time(6.0)
			generic_timer.start()
		2 :
			if generic_timer.is_stopped():
				get_tree().quit()
				
			
		

func _on_end_sequence_timer_timeout() -> void:
	#play whooshing noise 
	var _size = end_sequence_lights.size()
	if end_sequence < _size :
		# move a 3D audio player to each light and play sound from it 
		var _t = (_size - end_sequence)-1
		$main_handler/end_seq_click.global_position = end_sequence_lights[_t].global_position
		$main_handler/end_seq_click.play()
		#also lerp a spooky noise closer and closer to the player via the above behavior 
		end_sequence_lights[_t].visible = false
		end_sequence += 1
		$main_handler/end_sequence_timer.start()
		
func _resize_UI() :
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y
	var scale_x = viewportWidth / blink_fader.get_sprite_frames().get_frame_texture("default",0).get_size().x
	var scale_y = viewportHeight / blink_fader.get_sprite_frames().get_frame_texture("default",0).get_size().y
	blink_fader.set_position(Vector2(viewportWidth*0.5, viewportHeight*0.5))
	blink_fader.set_scale(Vector2(scale_x, scale_y))

func _swap_to_pause_menu() :
	if Input.is_action_pressed("escape") :
		if !pause_menu.swapping :
			if pause_menu.active :
				pause_menu.state = 4
			else :
				pause_menu.state = 1

func _on_auto_spook_timer_timeout() -> void:
	auto_spook = true
	$main_handler/auto_spook_timer.set_wait_time(10.0 + (randf()*10.0))
	spook_type = randi_range(0,spook_type_max)
	
func _light_flicker_spook_type_1() -> void:
	#flicker in front of the player 
	match spook_state : 
		0: #reset values 
			print("flicker spook 1 is active")
			flicker_spook_1 = true
			corridor_light_target = 0
			spook_state += 1
		1: #check for player
			if cl_pause_check :
				cl_pause_check = false
				corridor_light_target += 1
				if corridor_light_target > corridor_lights.size()-1:
					corridor_light_target = 0
					spook_state = 4 #cancel
			else :
				cl_pause_check = true
			generic_col_a.global_position = corridor_lights[corridor_light_target].global_position
			if generic_col_a.has_overlapping_bodies() :
				print("target found")
				#target either a light ahead or behind the player 
				var _array = [-1,0]
				corridor_light_target += _array[randi_range(0,1)]
				#wraparound check 
				if corridor_light_target > corridor_lights.size()-1:
					corridor_light_target = 0
				if corridor_light_target < 0 :
					corridor_light_target = corridor_lights.size()-1
				#set target
				spook_target = corridor_lights[corridor_light_target]
				spook_state = 2
		2: #move flicker light into position & start it 
			flicker_g_position = corridor_lights[corridor_light_target].global_position
			corridor_lights[corridor_light_target].global_position.y -= 200.0
			flicker_spook_light.global_position = flicker_g_position
			flicker_spook_light.rotation.y = corridor_lights[corridor_light_target].rotation.y
			flicker_spook_light.active = true
			spook_state += 1
		3: #when done flickering, reset everything 
			if flicker_spook_light.active == false :
				corridor_lights[corridor_light_target].global_position = flicker_g_position
				flicker_spook_light.global_position.y = -200.0
				spook_state += 1
		4:	#reset / cancel 
			print("flicker spook 1 is inactive")
			flicker_spook_1 = false
			corridor_light_target = 0
			spook_state = 0
			
			
func _light_flicker_spook_type_2() -> void:
	pass #removing this one for now 
			
func _gramophone_spook_type() -> void :
	#also only go active if player in halls 
	var _size = on_off_check.size()
	var _int = 0
	for n in _size :
		if on_off_check[n].on_off_check == true :
			_int += 1
	if float(_int) > float(_size) * 0.4 :
		if player_location == 0 :
			$room_handlers/rm_07_strange_music/g_phone_handler.activate_spook()
			
func _drifter_spook_type() -> void :
	var _position : int = -1
	for n in cc_update_colliders.size() :
		if cc_update_colliders[n].has_overlapping_bodies() :
			_position = n
	match _position :
		-1 :
			pass
		0 : #north > 1,3
			var _r = randi() % 2
			if _r == 0 : drifter.global_position = drifter.spawn_array[1].global_position
			else : drifter.global_position = drifter.spawn_array[3].global_position
		1 : #south > 0,2
			var _r = randi() % 2
			if _r == 0 : drifter.global_position = drifter.spawn_array[0].global_position
			else : drifter.global_position = drifter.spawn_array[2].global_position
		2 : #east > 2,3
			var _r = randi() % 2
			if _r == 0 : drifter.global_position = drifter.spawn_array[2].global_position
			else : drifter.global_position = drifter.spawn_array[3].global_position
		3 : #west > 0,1
			var _r = randi() % 2
			if _r == 0 : drifter.global_position = drifter.spawn_array[0].global_position
			else : drifter.global_position = drifter.spawn_array[1].global_position
			
	if _position != -1 :
		print("drifter active")
		drifter.active = true
		drifter.wait_mode = true
		
func _corridor_mann_spook_type() -> void :
	if player_location == 0 :
		if $entities/hall_mannequin_special.global_position.y == -200.0 :
			$entities/hall_mannequin_special.global_position.y = 0.36
		else :
			$entities/hall_mannequin_special.global_position.y = -200.0
			
func _hello_spook_type() -> void :
	#NOTE: some of this is in the process event under "hello_spook / hello_spook_node"
	var _rand = randf() #1 in 4 check to make this less common
	if _rand < 0.25 :
		general_audio_3D.stream = load("res://resources/sounds/hello.ogg")
		var _array = [$player_TPS/Head/behind_player/left,$player_TPS/Head/behind_player/right]
		hello_spook = true
		hello_spook_node = _array[randi_range(0,1)]
		general_audio_3D.unit_size = 2.0
		general_audio_3D.max_db = linear_to_db(0.05)
		general_audio_3D.max_distance = 7.0
		general_audio_3D.play()
	
func _notes_spook_type() -> void: 
	if note_spook.trigger :
		note_spook.trigger = false
	
		var _position : int = -1
		for n in cc_update_colliders.size() :
			if cc_update_colliders[n].has_overlapping_bodies() :
				_position = n
		match _position :
			-1 :
				pass
			0 : #north 
				note_spook.global_position = note_spawn_locations[0].global_position
			1 : #south
				note_spook.global_position = note_spawn_locations[1].global_position
			2 : #east 
				note_spook.global_position = note_spawn_locations[2].global_position
			3 : #west
				note_spook.global_position = note_spawn_locations[3].global_position
				
		if _position != -1 :
			note_target_int += 1
			if note_target_int > note_dialogue.size() -1:
				note_target_int = note_dialogue.size() -1
			note_spook.dialogue_string = note_dialogue[note_target_int]
	
func _pipes_spook_type() -> void:
	#also do a look angle check to make sure thye're facing AWAY from the center of the map
	if player_location != 0:
		if !is_facing_center:
			for n in pipe_spook_vis.size() :
				pipe_spook_vis[n].visible = !pipe_spook_vis[n].visible

	
	
		
	
	
#------------------------------------------------------------------------------
#save and load functions 
#------------------------------------------------------------------------------

func _update_save_file() : #saves info to the save_data blob
	save_data.master_audio = db_to_linear(AudioServer.get_bus_volume_db(0))
	var _win = DisplayServer.window_get_mode(0)
	if _win == 0 :
		save_data.fullscreen = 0
	else :
		save_data.fullscreen = 1
	_save_on_off_check()
	
func _update_load_file() : #loads info from the save_data blob
	_load_on_off_check()
	AudioServer.set_bus_volume_db(0,linear_to_db(save_data.master_audio))
	if save_data.fullscreen :
		DisplayServer.window_set_mode(4,0)
	else : 
		DisplayServer.window_set_mode(0,0)
	_resize_UI()
	_set_complete()

func _save_game() : #saves to file 
	var json_string = JSON.stringify(save_data)
	var json_file = FileAccess.open("user://savegame.json",FileAccess.WRITE)
	json_file.store_line(json_string)
	json_file.close()
	print("saved")
	print(save_data)
	
func _load_game() : # loads from file 
	var json_file = FileAccess.open("user://savegame.json",FileAccess.READ)
	var json_string = json_file.get_as_text()
	json_file.close()
	save_data = JSON.parse_string(json_string)
	print("loaded")
	print(save_data)
	
func _load_on_off_check() :
	for n in on_off_check.size() :
		on_off_check[n].on_off_check = save_data.on_off_check[n]

func _save_on_off_check() :
	for n in on_off_check.size() :
		save_data.on_off_check[n] = on_off_check[n].on_off_check
	
func _set_complete() :
	for n in save_data.on_off_check.size():
		if save_data.on_off_check[n] == true :
			if on_off_check[n].has_method("set_complete"):
				on_off_check[n]._set_complete()
				print("setting event" + str(n) + "to completed")
