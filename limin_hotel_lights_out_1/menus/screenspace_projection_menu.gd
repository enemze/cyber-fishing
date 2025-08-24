extends Node3D

@export_enum("MENU","MAIN") var menu_or_main : String = "MENU"
@export var camera : Camera3D
@export var aim_ray : RayCast3D

@onready var mesh : MeshInstance3D = $StaticBody3D/MeshInstance3D
@onready var target : StaticBody3D = $StaticBody3D
@onready var blink_anim : AnimatedSprite2D = $Control/blink_sprite
@onready var cam_main_pos : Node3D = $main_menu_cam_position
@onready var cam_optn_pos : Node3D = $option_menu_cam_position
@onready var world_environ : Environment = $"../WorldEnvironment".environment
@onready var vision_fader : ColorRect = $Control/fader_rect

var state = 0
var collider_array : Array
var screen_array : Array
var button_selected : int = -1
var blink_frames_max : int = 0
var start_level

var click_drag_start_position : Vector2 = Vector2.ZERO
var volume_debug : float = 100.0
var slider_target : StaticBody3D

var hold_fill : float= 5.0

var version : int = 08012025

var credits_state : int = 0
var draw_credits_value : float = 3.0
var draw_credits : float = draw_credits_value

var target_text : Label3D 

var save_data : Dictionary = {
	"version" : version,
	"master_audio" : 1.0,
	"brightness" : 1.0,
	"fullscreen" : true,
	"on_off_check" : [],
	"keys" : [],
	"lights_to_hide_int" : 0.0,
	"post_ending" : false
	}

var blank_data : Dictionary 
var cancel_goto_secret : bool = false

var fader_alpha : float = 2.0 #set this to 2.0 once we're done debugging 
var fade_val : float = 0.6
var fade_dir : float = -1.0 #set this to -1.0 once we're done debugging 
var fade_in_out : int = 0
var fade_timer : float = 0.5
signal fade_state(in_or_out)
signal sig_fade_clear

func _ready():
	
	randomize()
	vision_fader.visible = true
	#blink_anim.visible = true
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#blink_anim.set_frame_and_progress(0,0.0)
	#blink_frames_max = blink_anim.sprite_frames.get_frame_count("default") - 1
	
	#credits stuff
	#$Control/Control.modulate.a = 0.0
	#$Control/Control2.modulate.a = 0.0
	
	camera.global_position = cam_main_pos.global_position
	camera.rotation = cam_main_pos.rotation
	
	world_environ = $"../WorldEnvironment".environment
	
	collider_array = [
		$StaticBody3D3,
		$StaticBody3D,
		$StaticBody3D2,
		$StaticBody3D6, 
		$StaticBody3D5, 
		$StaticBody3D4, 
		$StaticBody3D7,
		$StaticBody3D8,
		$light_Switch
		]
	
	blank_data = save_data.duplicate()
	
	#remove this line if the debug works 
	#DirAccess.remove_absolute("user://savegame.json")
		
	if !FileAccess.file_exists("user://savegame.json") :
		_save_options()
		_clear_save()
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN,0)
		_resize_UI()
	else :
		_load_options()
	
	start_level = preload("res://MainRenderContainer.tscn") as PackedScene
	#random scene selection + post-game scene 
	#if save_data.post_ending :
		#cancel_goto_secret = true
		#print("loading game layout 1") #set this as our special level 
		#start_level = preload("res://levels/MainRenderContainer_3.tscn") as PackedScene
	#else : 
		#if menu_or_main == "MENU" :
			#var flip_coin : int = randi_range(0,1)
			##flip_coin = 1 #use this to force load the original layout 
			#if flip_coin == 0 :
				#print("loading game layout 1")
				#start_level = preload("res://MainRenderContainer.tscn") as PackedScene
			#if flip_coin == 1 :
				#print("loading game layout 2")
				#start_level = preload("res://levels/MainRenderContainer_2.tscn") as PackedScene
	
func _physics_process(delta: float) -> void:
	
	_fade_handler(delta)
	
	if !cancel_goto_secret :
		var _end_value = 4
		credits_state = _end_value
		if credits_state != _end_value :
			pass
			#credits stuff
			#match credits_state :
				#0 : #fade into / fade out of basic credits 
					#var _rate = 0.5
					#draw_credits -= _rate*delta
					#$Control/Control/RichTextLabel.position.y = get_viewport().size.y * 0.01
					#$Control/Control/Sprite2D.position.y = get_viewport().size.y * 0.34
					#$Control/Control/AnimatedSprite2D.position.y = get_viewport().size.y * 0.75
					#
					#if draw_credits < draw_credits_value*0.4 :
						#if $Control/Control.modulate.a > 0.0:
							#$Control/Control.modulate.a -= 1.0*delta
					#else :
						#if draw_credits < draw_credits_value*0.85 :
							#if $Control/Control.modulate.a < 1.0:
								#$Control/Control.modulate.a += 1.0*delta
							#
					#if draw_credits < draw_credits_value * 0.1 :
						#credits_state += 1
				#1 : #fade into / out of epilepsy warning 
					#var _fullscreen = DisplayServer.window_get_mode(0)
					#if _fullscreen == DisplayServer.WINDOW_MODE_FULLSCREEN :
						#$Control/Control2/RichTextLabel.position.y = get_viewport().size.y * 0.20
					#else :
						#$Control/Control2/RichTextLabel.position.y = get_viewport().size.y * 0.05
					#if $Control/Control2.modulate.a < 1.0:
						#$Control/Control2.modulate.a += 1.0*delta
					#else :
						#draw_credits = draw_credits_value
						#credits_state +=1 
				#2 :
					#var _rate = 0.5
					#draw_credits -= _rate*delta
					#if draw_credits <= 0.0 :
						#credits_state += 1
				#3 :
					#if $Control/Control2.modulate.a > 0.0:
						#$Control/Control2.modulate.a -= 1.0*delta
					#else :
						#credits_state +=1 
						#if !blink_anim.is_playing():
							#blink_anim.play()
		else :	
			projection_button_get()

			if Input.is_action_just_pressed("shoot") :
				if state == 0:
					if button_selected != -1:
						$switch_flip.set_pitch_scale(randf_range(0.75,1.25))
						$switch_flip.play()
						state = button_selected
						print(state)
						
			match state :
				0 : #base neutral state
					pass
				1 : #start game
					_start_game()
				2 : #quit game
					_quit_game()
				3 : #goto options 
					_goto_options()
				4 : #go back
					_save_options()
					_goto_main()
				5 : #fullscreen toggle
					_fullscreen_toggle()
					state = 0
				6: #volume adjust
					_click_drag_slider()
				7: #clear save 
					_click_hold_reset(delta)
				8: #brightness slider
					brightness_slider()
				9: #turn on room light
					room_light_on()
					
	else :
		save_data.post_ending = false 
		_save_options()
		_clear_save()
		get_tree().change_scene_to_packed(start_level)
		cancel_goto_secret = false

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
	vision_fader.modulate.a = fader_alpha
			
func _start_game() -> void:
	fade_timer = 2.0
	if fader_alpha >= 1.0 :
		get_tree().change_scene_to_packed(start_level)

func _quit_game() -> void:
		get_tree().quit()
			
func _goto_options() -> void:
		state = 0
		camera.global_position = cam_optn_pos.global_position
		camera.rotation = cam_optn_pos.rotation

func _goto_main() -> void:
		state = 0
		camera.global_position = cam_main_pos.global_position
		camera.rotation = cam_main_pos.rotation
		blink_anim.play()
			
func _fullscreen_toggle() -> void :
	var _win = DisplayServer.window_get_mode(0)
	if _win == 0 :
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN,0)
	else :
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED,0)
	_resize_UI()
			
func _resize_UI() -> void:
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y
	var scale_x = viewportWidth / blink_anim.get_sprite_frames().get_frame_texture("default",0).get_size().x
	var scale_y = viewportHeight / blink_anim.get_sprite_frames().get_frame_texture("default",0).get_size().y
	vision_fader.set_position(Vector2(0.0, 0.0))
	#vision_fader.set_scale(Vector2(scale_x, scale_y))
	vision_fader.set_size(Vector2(viewportWidth, viewportHeight))
	
func _click_drag_slider() -> void:
	slider_target.trigger = true #keeps screen on even when moving off of it 
	
	var _bus_index = AudioServer.get_bus_index("Master")
	
	if click_drag_start_position == Vector2.ZERO :
		click_drag_start_position = get_viewport().get_mouse_position()	
		volume_debug = db_to_linear(AudioServer.get_bus_volume_db(_bus_index))
	
	var new_pos = get_viewport().get_mouse_position()
	new_pos = volume_debug + (click_drag_start_position.x - new_pos.x)*-0.01
	
	var _value = clamp(new_pos,0.0,1.0)
	
	target.text = "Volume\n" + str(floor(_value*100.0))
	
	AudioServer.set_bus_volume_db(_bus_index,linear_to_db(_value))
		
	if Input.is_action_just_released("shoot") :
		click_drag_start_position = Vector2.ZERO
		volume_debug = _value
		state = 0
		
func brightness_slider() -> void:
	slider_target.trigger = true #keeps screen on even when moving off of it 
	var _environ : Environment = $"../WorldEnvironment".environment
	
	if click_drag_start_position == Vector2.ZERO :
		click_drag_start_position = get_viewport().get_mouse_position()	
		save_data.brightness = _environ.adjustment_brightness
	
	var new_pos = get_viewport().get_mouse_position()
	new_pos = save_data.brightness + (click_drag_start_position.x - new_pos.x)*-0.01
	
	var _value = clamp(new_pos,0.0,2.0)
	
	target_text.text = "Bright\nNess\n" + str(floor(_value*100.0))
	
	_environ.adjustment_brightness = _value
	
	if Input.is_action_just_released("shoot") :
		click_drag_start_position = Vector2.ZERO
		save_data.brightness = _value
		state = 0
		
		
func _click_hold_reset(delta) -> void:
	slider_target.trigger = true
	if  Input.is_action_pressed("shoot") :
		hold_fill -= 1.0*delta
		hold_fill = clamp(hold_fill,0.0,5.0)
		target_text.text = str(ceil(hold_fill))
		if hold_fill == 0.0 :
			slider_target.audio_played_tag = false
			state = 0
			_clear_save()
			hold_fill = 5.0
			target_text.text = "clear\nsave"
	else :
		target_text.text = "clear\nsave"
		hold_fill = 5.0
		state = 0

func room_light_on() :
	if $light_Switch.toggle == false :	
		$"../MainMenuRender2/dancer_1".global_position.z += 0.8
		$"../MainMenuRender2/CandleStick".visible = true
		$light_Switch.toggle = true		
		state = 0
	
func _clear_save() -> void:
	if FileAccess.file_exists("user://savegame.json") :
		var json_file = FileAccess.open("user://savegame.json",FileAccess.READ)
		var json_string = json_file.get_as_text()
		json_file.close()
		save_data = JSON.parse_string(json_string)
		save_data.version = 00
		json_string = JSON.stringify(save_data)
		json_file = FileAccess.open("user://savegame.json",FileAccess.WRITE)
		json_file.store_line(json_string)
		json_file.close()
		print("save tagged for erasure")
		print(save_data)

func _load_options() -> void:
	if FileAccess.file_exists("user://savegame.json") :
		var json_file = FileAccess.open("user://savegame.json",FileAccess.READ)
		var json_string = json_file.get_as_text()
		json_file.close()
		save_data = JSON.parse_string(json_string)
		AudioServer.set_bus_volume_db(0,linear_to_db(save_data.master_audio))
		world_environ.adjustment_brightness = save_data.brightness 
		if save_data.fullscreen :
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN,0)
		else : 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED,0)
		_resize_UI()

func _save_options() -> void:
	#var json_file = FileAccess.open("user://savegame.json",FileAccess.READ)
	#var json_string = json_file.get_as_text()
	#print(json_string)
	#json_file.close()
	#save_data = JSON.parse_string(json_string)
	save_data.master_audio = db_to_linear(AudioServer.get_bus_volume_db(0))
	save_data.brightness = world_environ.adjustment_brightness
	var _win = DisplayServer.window_get_mode(0)
	if _win == 0 :
		save_data.fullscreen = 0
	else :
		save_data.fullscreen = 1
	var json_string = JSON.stringify(save_data)
	var json_file = FileAccess.open("user://savegame.json",FileAccess.WRITE)
	json_file.store_line(json_string)
	json_file.close()

func projection_button_get() -> void:
		var _camera = get_viewport().get_camera_3d()
		var _viewport = get_viewport().size
		var _ray_origin = _camera.project_ray_origin(_viewport/2)
		var _spread = get_viewport().get_mouse_position()
		var viewportWidth = get_viewport().size.x
		var viewportHeight = get_viewport().size.y
		var scale_x = viewportWidth / 640.0
		var scale_y = viewportHeight / 320.0
		_spread.x -= 320.0*scale_x
		_spread.y -= 160.0*scale_y
		
		var _range = 50.0
		var _ray_end = (_ray_origin + camera.project_ray_normal((_viewport/2)+Vector2i(_spread))*_range)
			
		var _new_intersection = PhysicsRayQueryParameters3D.create(_ray_origin,_ray_end)
		_new_intersection.set_collision_mask(0b00000000_00000000_00000000_00000001)
		
		var _intersection = get_world_3d().direct_space_state.intersect_ray(_new_intersection)
		
		var _collision
			
		if not _intersection.is_empty() :
			_collision = [_intersection.collider,_intersection.position]
		else :
			_collision = [null, _ray_end]	
			
		aim_ray.look_at(_collision[1])
		
		var _toggle : int = -1
			
		for n in collider_array.size() :
			if _collision[0] == collider_array[n] :
				if _collision[0] != null :
					if state != 6:
						if state != 7:
							if state != 8 :
								collider_array[n].trigger = true
								target_text = collider_array[n].my_text
								_toggle = collider_array[n].state
								if _toggle == 6 :
									slider_target = collider_array[n]
								if _toggle == 7 :
									slider_target = collider_array[n]
								if _toggle == 8 :
									slider_target = collider_array[n]
		button_selected = _toggle
	
		
