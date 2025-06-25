extends Node3D

@export_enum("MENU","MAIN") var menu_or_main : String = "MENU"
@export var world : Node3D
@export var player : CharacterBody3D
@export var aim_ray : RayCast3D

@onready var mesh : MeshInstance3D = $StaticBody3D/MeshInstance3D
@onready var target : StaticBody3D = $StaticBody3D
@onready var blink_anim : AnimatedSprite2D = $Control/blink_sprite
@onready var cam_main_pos : Node3D = $main_menu_cam_position
@onready var cam_optn_pos : Node3D = $"../camera_position"

var state = 0
var collider_array : Array
var screen_array : Array
var button_selected : int = -1
var blink_frames_max : int = 0
var start_level
var camera
var active : bool = false
var swapping : bool = false
var slider_target : StaticBody3D

var click_drag_start_position : Vector2 = Vector2.ZERO
var volume_debug : float = 100.0

var pause_rotation_save : Vector3 = Vector3.ZERO

func _ready():
	
	blink_anim.visible = true
	_resize_UI()
	blink_anim.set_frame_and_progress(0,0.0)
	blink_anim.play()
	blink_frames_max = blink_anim.sprite_frames.get_frame_count("default") - 1
	
	camera = player.camera
	
	#camera.global_position = cam_main_pos.global_position
	#camera.rotation = cam_main_pos.rotation
	
	collider_array = [
		$StaticBody3D6, #back
		$StaticBody3D5, #fullscreen
		$StaticBody3D4, #audio
		]
	
func _process(delta: float) -> void:
		
	match state :
		0 : #base neutral state
			pass
		1 : #swap to
			_start_game()
		2 : #quit game
			_quit_game()
		3 : #goto options 
			_goto_options()
		4 : #go back
			_goto_main()
		5 : #fullscreen toggle
			_fullscreen_toggle()
			state = 0
		6: #volume adjust
			_click_drag_slider()
	
	if active :
		projection_button_get()

		if Input.is_action_just_pressed("shoot") :
			if state == 0:
				if button_selected != -1:
					$switch_flip.set_pitch_scale(randf_range(0.75,1.25))
					$switch_flip.play()
					state = button_selected
			
func _start_game() -> void:
	if blink_anim.frame == 0.0 :
		print("done swapping to pause")
		state = 0
		pause_rotation_save.x = player.camera.rotation.x
		pause_rotation_save.y = player.rotation.y
		player.camera.global_position = cam_optn_pos.global_position
		player.camera.global_rotation = cam_optn_pos.rotation
		player.look_lock = true
		player.move_lock = true
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		active = true
		swapping = false
		blink_anim.play()
	else :
		swapping = true
		if !blink_anim.is_playing() :
			blink_anim.play_backwards()
			
func _quit_game() -> void:
	if blink_anim.frame == 0.0 :
		get_tree().quit()
	else :
		if !blink_anim.is_playing() :
			blink_anim.play_backwards()
			
func _goto_options() -> void:
	if blink_anim.frame == 0.0 :
		state = 0
		#camera.global_position = cam_optn_pos.global_position
		#camera.rotation = cam_optn_pos.rotation
		blink_anim.play()
	else :
		if !blink_anim.is_playing() :
			blink_anim.play_backwards()

func _goto_main() -> void:
	if blink_anim.frame == 0.0 :
		print("done swapping to main")
		state = 0
		active = false
		player.camera.global_position = player.head.global_position
		player.camera.rotation.x = pause_rotation_save.x
		player.camera.rotation.y = 0.0
		player.look_lock = false
		player.move_lock = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		blink_anim.play()
		swapping = false
	else :
		swapping = true
		if !blink_anim.is_playing() :
			blink_anim.play_backwards()
			
func _fullscreen_toggle() -> void :
	var _win = DisplayServer.window_get_mode(0)
	if _win == 0 :
		DisplayServer.window_set_mode(4,0)
	else :
		DisplayServer.window_set_mode(0,0)
	_resize_UI()
			
func _resize_UI() -> void:
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y
	var scale_x = viewportWidth / blink_anim.get_sprite_frames().get_frame_texture("default",0).get_size().x
	var scale_y = viewportHeight / blink_anim.get_sprite_frames().get_frame_texture("default",0).get_size().y
	blink_anim.set_position(Vector2(viewportWidth*0.5, viewportHeight*0.5))
	blink_anim.set_scale(Vector2(scale_x, scale_y))
	
func _click_drag_slider() -> void:
	slider_target.trigger = true #keeps screen on even when moving off of it 
	
	var _bus_index = AudioServer.get_bus_index("Master")
	
	if click_drag_start_position == Vector2.ZERO :
		click_drag_start_position = get_viewport().get_mouse_position()	
		volume_debug = db_to_linear(AudioServer.get_bus_volume_db(_bus_index))
	
	var new_pos = get_viewport().get_mouse_position()
	new_pos = volume_debug + (click_drag_start_position.x - new_pos.x)*-0.01
	
	var _value = clamp(new_pos,0.0,1.0)
	
	$StaticBody3D4/Label3D.text = "Volume\n" + str(floor(_value*100.0))
	
	AudioServer.set_bus_volume_db(_bus_index,linear_to_db(_value))
		
	if Input.is_action_just_released("shoot") :
		click_drag_start_position = Vector2.ZERO
		volume_debug = _value
		state = 0
	
	
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
			
		#aim_ray.look_at(_collision[1])
		
		var _toggle : int = -1
			
		for n in collider_array.size() :
			if _collision[0] == collider_array[n] :
				if state != 6:
					collider_array[n].trigger = true
					_toggle = collider_array[n].state
					if _toggle == 6 :
						slider_target = collider_array[n]
				
		button_selected = _toggle
	
		
